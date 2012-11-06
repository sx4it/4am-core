# Host Installation

The script deploy.sh at the root of the repository takes care of the nginx/passenger/mysql/rails deployment.

```
wget --no-check-certificate https://raw.github.com/sx4it/4am-ui/master/deploy.sh
bash deploy.sh --db-install --db-engine mysql
```

# Web App deployment

Checkout the github repo locally, and run:

```
export CORE_4AM='<ip>'
cap deploy:setup
```

after configuring the database and the 4am.yml file run:

```
cap deploy
cap deploy:migrate
```
the server should restart and run

# Adding a permanent redirection on the 80 port

Open the nginx conf file located in /opt/4am/nginx/conf/nginx.conf and add the
following lines. Do not forget to change the vhost names.

```
server {
        listen   80;
        server_name  ssl.sx4it.com;
        rewrite ^/(.*) https://ssl.sx4it.com/$1 permanent;
}
```
