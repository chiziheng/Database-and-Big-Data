#!/bin/bash
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done
while [ ! -f /var/lib/cloud/instances/i-*/boot-finished ]; do sleep 1; done
echo "Installing MongoDB"
sudo apt-get update
sudo apt install unzip -y

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod

echo "Openning MongoDB port for remote connection" 
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
sudo systemctl restart mongod
sleep 5 #wait for restart to finish

unzip kindle_metadata_final.zip

echo "Executing Mongodb commands"
mongo < /home/ubuntu/mongo_commands.js

echo "Importing data in to mongodb"
mongoimport --db kindle_metadata --collection kindle_metadata --file /home/ubuntu/kindle_metadata_final.json --legacy
sudo sed -i 's/#security:/security:\n  authorization: enabled/g' /etc/mongod.conf # enable authantication for mongodb
sudo systemctl restart mongod
rm -rf mongo_commands.js kindle_metadata_final.json Mongodb_setup_script.sh

echo "MongoDB setup finished"

#sed -i -e 's/\r$//' Mongodb_setup_script.sh
touch done.txt
