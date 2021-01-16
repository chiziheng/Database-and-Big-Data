#!/bin/bash
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done
while [ ! -f /var/lib/cloud/instances/i-*/boot-finished ]; do sleep 1; done
echo "Installing Mysql on the instance"
sudo apt update
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -q -y install mysql-server
sudo apt install unzip

echo "Creating root user and test user and assign root user with password "
sudo mysql -e 'update mysql.user set plugin = "mysql_native_password" where User="root"'
sudo mysql -e 'create user "root"@"%" identified by "&V]xM);}^$ts&9U-hC[C"'
sudo mysql -e 'create user "test_user"@"%" identified by "test_user"'
sudo mysql -e 'grant all privileges on *.* to "root"@"%" with grant option'
sudo mysql -e 'flush privileges'
sudo service mysql restart
wait

echo "Opening the port for Mysql for remote connect"
sudo systemctl stop mysql
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf 
sudo systemctl restart mysql
wait

wget -c https://istd50043.s3-ap-southeast-1.amazonaws.com/kindle-reviews.zip -O kindle-reviews.zip

echo "Executing SQL commands to create table and unzipping data file"
unzip kindle-reviews.zip
echo "Wait for the data to be loaded into table"
sudo mysql -e 'source /home/ubuntu/sql_commands.sql'
wait

echo "Finish loading data into Mysql table"
rm -rf kindle_reviews.json kindle_reviews.csv kindle-reviews.zip sql_commands.sql
echo "Mysql setup finished"
touch done.txt
