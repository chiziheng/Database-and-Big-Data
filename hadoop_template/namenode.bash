#!/bin/bash
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done
while [ ! -f /var/lib/cloud/instances/i-*/boot-finished ]; do sleep 1; done
sudo apt update -y
sudo apt install ssh -y
# echo "172.31.70.117 com.g15.namenode" | sudo tee -a  /etc/hosts
# echo "172.31.65.48 com.g15.datanode1" | sudo tee -a  /etc/hosts
[[hosts]]
sudo hostnamectl set-hostname com.g15.namenode
sudo adduser --disabled-password  --gecos '' hadoop
sudo sh -c 'echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-hadoop'
sudo sysctl vm.swappiness=10
# sudo su - hadoop
sudo -u hadoop mkdir /home/hadoop/.ssh
# sudo cp /home/ubuntu/g15pubkey /home/ubuntu/.ssh/authorized_keys
sudo cp /home/ubuntu/g15key /home/ubuntu/.ssh/id_rsa
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa
sudo -u hadoop sudo cp /home/ubuntu/.ssh/authorized_keys /home/hadoop/.ssh/authorized_keys
sudo -u hadoop sudo cp /home/ubuntu/.ssh/id_rsa /home/hadoop/.ssh/id_rsa
sudo -u hadoop sudo chmod 600 /home/ubuntu/.ssh/id_rsa
sudo -u hadoop sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
sudo -u hadoop sudo chmod 600 /home/hadoop/.ssh/id_rsa
sudo -u hadoop sudo chmod 600 /home/hadoop/.ssh/authorized_keys
sudo chown hadoop:hadoop -R /home/hadoop/.ssh/
sudo -u hadoop sudo apt install -y openjdk-8-jdk
sudo -u hadoop mkdir /home/hadoop/download

sudo -u hadoop wget --directory-prefix=/home/hadoop/download/ http://mirror.cogentco.com/pub/apache/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz
sudo -u hadoop tar zxf /home/hadoop/download/hadoop-3.3.0.tar.gz -C /home/hadoop/download

export JH="\/usr\/lib\/jvm\/java-8-openjdk-amd64"
sudo -u hadoop sed -i "s/# export JAVA_HOME=.*/export\ JAVA_HOME=${JH}/g" /home/hadoop/download/hadoop-3.3.0/etc/hadoop/hadoop-env.sh

MASTER=com.g15.namenode
WORKERS="[[workers]]"

sudo -u hadoop echo -e "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<\x21-- Put site-specific property overrides in this file. -->
<configuration>
<property>
<name>fs.defaultFS</name>
<value>hdfs://${MASTER}:9000</value>
</property>
</configuration>
" | sudo -u hadoop tee /home/hadoop/download/hadoop-3.3.0/etc/hadoop/core-site.xml

sudo -u hadoop echo -e "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<\x21-- Put site-specific property overrides in this file. -->
<configuration>
<property>
<name>dfs.replication</name>
<value>3</value>
</property>
<property>
<name>dfs.namenode.name.dir</name>
<value>file:/mnt/hadoop/namenode</value>
</property>
<property>
<name>dfs.datanode.data.dir</name>
<value>file:/mnt/hadoop/datanode</value>
</property>
</configuration>
" | sudo -u hadoop tee /home/hadoop/download/hadoop-3.3.0/etc/hadoop/hdfs-site.xml

sudo -u hadoop echo -e "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<\x21-- Put site-specific property overrides in this file. -->
<configuration>
<\x21-- Site specific YARN configuration properties -->
<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
<description>Tell NodeManagers that there will be an auxiliary
service called mapreduce.shuffle
that they need to implement
</description>
</property>
<property>
<name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
<value>org.apache.hadoop.mapred.ShuffleHandler</value>
<description>A class name as a means to implement the service
</description>
</property>
<property>
<name>yarn.resourcemanager.hostname</name>
<value>${MASTER}</value>
</property>
</configuration>
" | sudo -u hadoop tee /home/hadoop/download/hadoop-3.3.0/etc/hadoop/yarn-site.xml

# namenode pri ip
sudo -u hadoop echo -e "<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<\x21-- Put site-specific property overrides in this file. -->
<configuration>
<\x21-- Site specific YARN configuration properties -->
<property>
<name>mapreduce.job.tracker</name>
<value>hdfs://[[namenodepriip]]:8001</value>
<final>true</final>
</property>
<property>
<name>yarn.app.mapreduce.am.env</name>
<value>HADOOP_MAPRED_HOME=/opt/hadoop-3.3.0/</value>
</property>
<property>
<name>mapreduce.map.env</name>
<value>HADOOP_MAPRED_HOME=/opt/hadoop-3.3.0/</value>
</property>
<property>
<name>mapreduce.reduce.env</name>
<value>HADOOP_MAPRED_HOME=/opt/hadoop-3.3.0/</value>
</property>
</configuration>
" | sudo -u hadoop tee /home/hadoop/download/hadoop-3.3.0/etc/hadoop/mapred-site.xml

sudo -u hadoop rm /home/hadoop/download/hadoop-3.3.0/etc/hadoop/workers
for ip in ${WORKERS}; do sudo -u hadoop echo -e "${ip}" | sudo -u hadoop tee -a /home/hadoop/download/hadoop-3.3.0/etc/hadoop/workers; done

sudo -u hadoop sudo mv /home/hadoop/download/hadoop-3.3.0 /opt/

sudo -u hadoop sudo mkdir -p /mnt/hadoop/namenode/hadoop-${USER}
sudo -u hadoop sudo chown -R hadoop:hadoop /mnt/hadoop/namenode
yes | sudo -u hadoop /opt/hadoop-3.3.0/bin/hdfs namenode -format

# sudo -u hadoop /opt/hadoop-3.3.0/sbin/start-dfs.sh && sudo -u hadoop /opt/hadoop-3.3.0/sbin/start-yarn.sh

# sqoop
sudo -u hadoop wget --directory-prefix=/home/hadoop/download/ http://mirror.cogentco.com/pub/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
sudo -u hadoop tar zxf /home/hadoop/download/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -C /home/hadoop/download

sudo -u hadoop cp /home/hadoop/download/sqoop-1.4.7.bin__hadoop-2.6.0/conf/sqoop-env-template.sh /home/hadoop/download/sqoop-1.4.7.bin__hadoop-2.6.0/conf/sqoop-env.sh

export HD="\/opt\/hadoop-3.3.0"

sudo -u hadoop sed -i "s/#export HADOOP_COMMON_HOME=.*/export HADOOP_COMMON_HOME=${HD}/g" /home/hadoop/download/sqoop-1.4.7.bin__hadoop-2.6.0/conf/sqoop-env.sh

sudo -u hadoop sed -i "s/#export HADOOP_MAPRED_HOME=.*/export HADOOP_MAPRED_HOME=${HD}/g" /home/hadoop/download/sqoop-1.4.7.bin__hadoop-2.6.0/conf/sqoop-env.sh

sudo -u hadoop wget --directory-prefix=/home/hadoop/download/ https://repo1.maven.org/maven2/commons-lang/commons-lang/2.6/commons-lang-2.6.jar

sudo -u hadoop cp /home/hadoop/download/commons-lang-2.6.jar /home/hadoop/download/sqoop-1.4.7.bin__hadoop-2.6.0/lib/

sudo cp -rf /home/hadoop/download/sqoop-1.4.7.bin__hadoop-2.6.0 /opt/sqoop-1.4.7
sudo apt install libmysql-java -y

sudo ln -snvf /usr/share/java/mysql-connector-java.jar /opt/sqoop-1.4.7/lib/mysql-connector-java.jar

export PATH=$PATH:/opt/sqoop-1.4.7/bin/

sudo chown -R hadoop /opt/sqoop-1.4.7/

# mongo
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod

# spark
sudo -u hadoop wget --directory-prefix=/home/hadoop/download/ wget http://mirror.cogentco.com/pub/apache/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz

sudo -u hadoop tar zxf /home/hadoop/download/spark-3.0.1-bin-hadoop3.2.tgz -C /home/hadoop/download

sudo -u hadoop cp /home/hadoop/download/spark-3.0.1-bin-hadoop3.2/conf/spark-env.sh.template /home/hadoop/download/spark-3.0.1-bin-hadoop3.2/conf/spark-env.sh

sudo -u hadoop echo -e "
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/opt/hadoop-3.3.0
export SPARK_HOME=/opt/spark-3.0.1-bin-hadoop3.2
export SPARK_CONF_DIR=\${SPARK_HOME}/conf
export HADOOP_CONF_DIR=\${HADOOP_HOME}/etc/hadoop
export YARN_CONF_DIR=\${HADOOP_HOME}/etc/hadoop
export SPARK_EXECUTOR_CORES=1
export SPARK_EXECUTOR_MEMORY=2G
export SPARK_DRIVER_MEMORY=1G
export PYSPARK_PYTHON=python3
" | sudo -u hadoop tee -a /home/hadoop/download/spark-3.0.1-bin-hadoop3.2/conf/spark-env.sh

for ip in ${WORKERS};
do sudo -u hadoop echo -e "${ip}" | sudo -u hadoop tee -a /home/hadoop/download/spark-3.0.1-bin-hadoop3.2/conf/slaves;
done

sudo mv /home/hadoop/download/spark-3.0.1-bin-hadoop3.2 /opt/
sudo chown -R hadoop:hadoop /opt/spark-3.0.1-bin-hadoop3.2

# install python
sudo apt remove python3 -y
sudo apt install software-properties-common nginx -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update -y
sudo apt remove python-3.5 -y
sudo apt remove python3.5-minimal -y
sudo apt remove python3-pip -y
sudo apt install python3.7 -y
wget https://bootstrap.pypa.io/get-pip.py
sudo python3.7 get-pip.py
sudo python3.7 -m pip install pyspark numpy py4j
echo -e "PYSPARK_PYTHON=\"/usr/bin/python3.7\"" | sudo tee -a /etc/environment 
echo -e "PYSPARK_DRIVER_PYTHON=\"/usr/bin/python3.7\"" | sudo tee -a /etc/environment 
sudo chmod +x analytics.bash
sudo apt update
exit
