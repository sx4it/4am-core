#!/bin/bash
 
set -e

## Default values
DEPLOYHOME=/opt/4am/
RUBYVERS="ruby-1.9.3-p194"
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
  --database mysql|postgresql
                        install and configure mysql or postgresql
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
        --database)
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
        libc6-dev ncurses-dev automake libtool bison subversion
        #gcc make
    }

    function mysql_install
    {
        #INSTALLER_LOG=/var/log/non-interactive-installer.log
        DEBIAN_FRONTEND=noninteractive apt-get install -q -y mysql-server pwgen
    
        # Alternatively you can set the mysql password with debconf-set-selections
        MYSQL_PASS=$(pwgen -s 12 1)
        mysql -uroot -e "UPDATE mysql.user SET password=PASSWORD('${MYSQL_PASS}') WHERE user='root'; FLUSH PRIVILEGES;"
        echo "MySQL Password set to '${MYSQL_PASS}'. Remember to delete ~/.mysql.passwd" | tee ~/.mysql.passwd
    }

    function addDedicatedUser
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
    
        echo "Installing package needed to build python, zmq and some python packages."
        yum -y install gcc gcc-c++ make \
        openssl-devel* zlib*.x86_64 \
        libuuid-devel mysql-devel \
        git
    }
 
    function addDedicatedUser
    {
        echo "Adding user..."
        adduser --system --home $DEPLOYHOME --shell /bin/bash  --create-home 4am
    }
else
    echo "Unsupported operating system, sorry."
    exit 1
fi

dependencies

if [ "$DATABASE" = "mysql" ]
then
    echo "Configuring $DATABASE"
    mysql_install
elif [ "$DATABASE" = "postgresql" ]
then
    postgresql_install
fi

#addDedicatedUser

 
echo "Installing rvm."
curl -L https://get.rvm.io | bash -s stable 
source /opt/4am//.rvm/scripts/rvm
echo "Installation of rvm completed."

echo "Installing  ruby through rvm."
rvm install ${RUBYVERS}
echo "Installation of ruby completed."

echo "Installing rails."
gem install rails
echo "Installation of rails completed."

echo "Cloning the git repo."
git clone git://github.com/sx4it/4am-ui.git
cd 4am-ui/
git checkout v2

echo "Installing the gem dependencies."
bundle install

#chmod +x ${DEPLOYHOME}4am-deploy.sh
#su -l -c ${DEPLOYHOME}4am-deploy.sh 4am
# Could be removed but not mandatory
#rm /opt/4am/4am-deploy.sh

cat <<EOF
Your installation is finished you now need to init the database.
Blabla 4am-init
EOF
 
exit 0
