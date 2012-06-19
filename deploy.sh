#!/bin/bash
 
set -e

## Default values
DEPLOYHOME=/opt/4am/
NGINXHOME=${DEPLOYHOME}/nginx/
NGINXWORKERS=$(awk '/^processor/ { N++} END { print N }' /proc/cpuinfo)
RUBYVERS="ruby-1.9.3-p194"
DBNAME="4am_experimental"
DBUSERNAME="root"
DBPASS=''
DBHOST='127.0.0.1'
## End default values
 
if [ $(id -u) -ne 0 ]
then
	echo "Must be run as root"
	exit 1
fi

function usage
{
    cat <<EOF
Usage: $0 [options]

Options:
  -h, --help            show this help message and exit
  --db-engine mysql|postgresql
                        configure mysql or postgresql
  --db-install          install the database
  --db-pass             pass for the database
  --home PATH
                        full path to the users home directory (default $DEPLOYHOME)
EOF
}

while :
do
    case "$1" in
        -h | --help)
        usage
        exit 0
        ;;
        --db-engine)
        #if [ "$2" != 'mysql' ] && [ "$2" != 'postgresql' ]
        if [ "$2" != 'mysql' ]
        then
            echo "Error: Unknown/unsupported engine: '$2'" >&2
            usage
            exit 1
        fi
        DATABASE=$2
        shift 2
        ;;
        --home)
        DEPLOYHOME=$2
        shift 2
        ;;
        --db-pass)
        DBPASS=$2
        shift 2
        ;;
        --db-install)
        DBINSTALL="yes"
        shift 1
        ;;
        -*)
        echo "Error: Unknown option: $1" >&2
        usage
        exit 1
        ;;
        *)  # No more options
        break
        ;;
    esac
done


# Define different functions depending on the operating system
if [ -f /etc/debian_version ]
then
    # DEBIAN
    function dependencies
    {
        echo "Updating the system."
        apt-get update && apt-get dist-upgrade -y
        
        echo "Installing some interesting package."
        /usr/bin/apt-get install -y build-essential openssl libreadline6 \
        libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev \
        libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf \
        libc6-dev ncurses-dev automake libtool bison subversion \
        libcurl4-openssl-dev # Needed for NGINX/Passenger
        #apt-get install libcurl4-openssl-dev
        #gcc make
    }

    function mysql_install
    {
        #INSTALLER_LOG=/var/log/non-interactive-installer.log
        DEBIAN_FRONTEND=noninteractive apt-get install -q -y mysql-server pwgen
    
        # Alternatively you can set the mysql password with debconf-set-selections
        DBPASS=$(pwgen -s 12 1)
        mysql -uroot -e "UPDATE mysql.user SET password=PASSWORD('${DBPASS}') WHERE user='root'; FLUSH PRIVILEGES;"
        echo "MySQL Password set to '${DBPASS}'. Remember to delete ~/.mysql.passwd" | tee ~/.mysql.passwd
    }

    function add_dedicated_user
    {
        echo "Adding user..."
        adduser --system --force-badname --home $DEPLOYHOME --shell /bin/bash --disabled-password 4am
    }

elif [ -f /etc/centos-release ]
then
    function dependencies
    {
        echo "Updating the system."
        yum update -y
    
        echo "Installing some interesting package."
        yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel \
        libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake \
        libtool bison git \
        curl-devel # Needed for passenger/nginx
    }
 
    function add_dedicated_user
    {
        echo "Adding user..."
        adduser --system --home $DEPLOYHOME --shell /bin/bash  --create-home 4am
    }

    function mysql_install
    {
        #INSTALLER_LOG=/var/log/non-interactive-installer.log
        rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm
        rpm -i http://mirrors.servercentral.net/fedora/epel/6/i386/epel-release-6-7.noarch.rpm

        echo "Installing mysql and pwgen."
        yum install -y mysql-server pwgen
    
        DBPASS=$(pwgen -s 12 1)
        /usr/bin/mysqladmin -u root password "${DBPASS}"
        echo "MySQL Password set to '${DBPASS}'. Remember to delete ~/.mysql.passwd" | tee ~/.mysql.passwd
    }
else
    echo "Unsupported operating system, sorry."
    exit 1
fi

#function mysql_create_db
#{
#    mysql -u root -p$MYSQL_PASS <<EOF
#  CREATE DATABASE $DBNAME CHARACTER SET utf8;
#EOF
#}

dependencies

if [ "$DBINSTALL" = "yes" ]
then
    if [ "$DATABASE" = "mysql" ]
    then
        echo "Configuring $DATABASE"
        mysql_install
    elif [ "$DATABASE" = "postgresql" ]
    then
        postgresql_install
    fi
fi

add_dedicated_user

function  install_rvm
{
    echo "Installing rvm."
    curl -L https://get.rvm.io | bash -s stable 
    source /usr/local/rvm/scripts/rvm 
    echo "Installation of rvm completed."
}

function  install_ruby
{
    echo "Installing  ruby through rvm."
    rvm install ${RUBYVERS}
    #rvm use ${RUBYVERS}
    echo "Installation of ruby completed."
}

install_rvm
install_ruby

echo "Cloning the git repo."
git clone git://github.com/sx4it/4am-ui.git --depth 1 --branch v2 $DEPLOYHOME/www/
echo "Entering the repo, rvmrc will be launched..."
cd $DEPLOYHOME/www/

### NGINX & PASSENGER
gem install passenger
passenger-install-nginx-module --auto --auto-download --prefix=${NGINXHOME}

## Self signed certificate for nginx and the client authentication
mkdir ${NGINXHOME}/conf/ssl
cat <<EOF > ${NGINXHOME}/conf/ssl/server-openssl.cnf
[ req ]
default_bits            = 4096
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
#attributes              = req_attributes
x509_extensions = v3_ca # The extentions to add to the self signed cert
# req_extensions = v3_req # The extensions to add to a certificate request
 encrypt_key            = no

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = FR
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = IDF
localityName                    = Locality Name (eg, city)
localityName_default            = Paris
0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = sx4it
organizationalUnitName          = Organizational Unit Name (eg, section)
#organizationalUnitName_default = 4am
commonName                      = Common Name (eg, YOUR name)
commonName_default              = $(hostname --fqdn)
emailAddress                    = Email Address
emailAddress_default            = contact@sx4it.com

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints = CA:true
EOF
echo -e "\n\n\n\n\n\n\n" | \
  openssl req -new -x509 -days 10000 -keyout ${NGINXHOME}/conf/ssl/server.key -out \
  ${NGINXHOME}/conf/ssl/server.crt -config ${NGINXHOME}/conf/ssl/server-openssl.cnf

chown -R 4am: $DEPLOYHOME/www/

mv ${NGINXHOME}/conf/nginx.conf ${NGINXHOME}/conf/nginx.conf.bak
cat <<EOF > ${NGINXHOME}/conf/nginx.conf
user  4am;
worker_processes  ${NGINXWORKERS};

error_log  logs/error.log  info;
pid        logs/nginx.pid;
events {
    worker_connections  1024;
}

http {
    passenger_root /usr/local/rvm/gems/ruby-1.9.3-p194@4am-ui/gems/passenger-3.0.13;
    passenger_ruby /usr/local/rvm/wrappers/ruby-1.9.3-p194@4am-ui/ruby;

    include       mime.types;
    default_type  application/octet-stream;

    error_log logs/error.log debug;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen          443 default_server ssl;
        server_name     \$hostname;

        access_log      logs/access.log;

        ssl_certificate      ssl/server.crt;
        ssl_certificate_key  ssl/server.key;

        # We need a CA, otherwise the client is not prompted for his certificate
        ssl_client_certificate  ssl/server.crt;
        ssl_verify_client       optional;

        ssl_session_timeout  5m;

        ssl_protocols  SSLv3 TLSv1;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers   on;

        root ${DEPLOYHOME}/www/;
        passenger_enabled on;
        passenger_set_cgi_param X-SSL_CLIENT_CERT \$ssl_client_raw_cert;
        passenger_set_cgi_param HTTP_X_FORWARDED_PROTO https;
        passenger_use_global_queue on;
        passenger_min_instances 2;
    }

    passenger_pre_start https://\$hostname/;
}
EOF

cat <<EOF > $DEPLOYHOME/www/config/database.yml
production:
  adapter: mysql2
  encoding: utf8
  database: $DBNAME
  pool: 10
  username: $DBUSERNAME
  password: $DBPASS
  host: $DBHOST
EOF

rake RAILS_ENV=production db:setup

cat <<EOF
Your installation is finished you now need to init the database.
Blabla 4am-init
EOF

exit 0
