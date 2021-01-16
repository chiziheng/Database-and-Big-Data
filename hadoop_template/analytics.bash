#!/bin/bash
# start analytics
# to find a way to wait all datanodes live
sudo -u hadoop /opt/hadoop-3.3.0/sbin/start-dfs.sh && sudo -u hadoop /opt/hadoop-3.3.0/sbin/start-yarn.sh
sudo mongoexport --collection=kindle_metadata --out=/home/hadoop/projectData/kindle_metadata.json 'mongodb://[[mongopriip]]/kindle_metadata' -u test_user -p test_user
sudo chown -R hadoop:hadoop /home/hadoop/projectData/

sudo -u hadoop /opt/sqoop-1.4.7/bin/sqoop import --bindir /opt/sqoop-1.4.7/lib/ --connect jdbc:mysql://[[mysqlpriip]]/kindle_reviews?useSSL=false --table Reviews --username root --password '&V]xM);}^$ts&9U-hC[C'
sudo -u hadoop /opt/hadoop-3.3.0/bin/hdfs dfs -rm -r /user/hadoop/Reviews
sudo -u hadoop /opt/sqoop-1.4.7/bin/sqoop import --bindir /opt/sqoop-1.4.7/lib/ --connect jdbc:mysql://[[mysqlpriip]]/kindle_reviews?useSSL=false --table Reviews --username root --password '&V]xM);}^$ts&9U-hC[C'

sudo -u hadoop /opt/hadoop-3.3.0/bin/hdfs dfs -mkdir -p /input/
sudo -u hadoop /opt/hadoop-3.3.0/bin/hdfs dfs -mkdir -p /input/pcc/
sudo -u hadoop /opt/hadoop-3.3.0/bin/hdfs dfs -mkdir -p /output/
sudo -u hadoop /opt/hadoop-3.3.0/bin/hdfs dfs -put /home/hadoop/projectData/kindle_metadata.json /input/pcc/

#running code command skip take in namenode's private
python3.7 pearson_correlation.py
sudo -u hadoop python3.7 tfidf.py
sudo -u hadoop /opt/hadoop-3.3.0/bin/hdfs dfs -get /output/reviews_tfidf_dir /home/hadoop/
sudo tar czf /var/www/html/reviews_tfidf.tar.gz /home/hadoop/reviews_tfidf_dir/
sudo cp /home/ubuntu/pearson_corr.txt /var/www/html/pearson_corr.txt

