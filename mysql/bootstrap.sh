
#!/usr/bin/env bash
cd /home/vagrant/config

# Load up .env
if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

DBHOST=${DB_HOST}
DBUSER=${DB_USER}
DBNAME=${DB_NAME}
DBPASSWD=${DB_PASS}

cd

apt-get update
apt-get install vim curl build-essential python-software-properties git

debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

# install mysql and admin interface
apt-get -y install mysql-server

mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'%' identified by '$DBPASSWD'"

cd /vagrant

# update mysql conf file to allow remote access to the db
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# restart service to apply confs
sudo service mysql restart