<h1>50.043 DataBase And Big Data Systems group project</h1>

2020 Term6 *Group 15*

```
Chen Yan         1003620
Zhang Shaozuo    1003756
Hua Guoqiang     1003783
Chi Ziheng       1003030
```

Please note that all our python scripts need Python3.7+ to run.

You can also find our automation script demonstration video here: [Video link](https://github.com/chenyan1998/50043.DataBase_And_BigData/blob/main/assets/automation_demo.mp4)


Table of Contents
- [1. Introduction](#1-introduction)
  - [1.1. Instances](#11-instances)
  - [1.2. File structure and role](#12-file-structure-and-role)
  - [1.3. Web application features](#13-web-application-features)
    - [1.3.1. Search](#131-search)
    - [1.3.2. Pagination](#132-pagination)
    - [1.3.3. Add a new book](#133-add-a-new-book)
    - [1.3.4. Add a new review](#134-add-a-new-review)
    - [1.3.5. Sort book by genre](#135-sort-book-by-genre)
    - [1.3.6. Reviews sort by time](#136-reviews-sort-by-time)
  - [1.4. Automation script features](#14-automation-script-features)
    - [1.4.1. Flexible](#141-flexible)
    - [1.4.2. Prompts](#142-prompts)
- [2. Usage](#2-usage)
  - [2.1. Set up environment](#21-set-up-environment)
  - [2.2. Set up credentials](#22-set-up-credentials)
  - [2.3. Automate it !](#23-automate-it-)
    - [2.3.1. Setting up WEB and database](#231-setting-up-web-and-database)
    - [2.3.2. Setting up Hadoop cluster](#232-setting-up-hadoop-cluster)
    - [2.3.3. Clean up](#233-clean-up)
  - [2.4. Note](#24-note)
- [3. Design](#3-design)
  - [3.1. Front end](#31-front-end)
    - [3.1.1. Web](#311-web)
    - [3.1.2. Middleware](#312-middleware)
  - [3.2. Database](#32-database)
    - [3.2.1. MySQL](#321-mysql)
  - [3.3. MongoDB](#33-mongodb)
  - [3.4. Data Processing](#34-data-processing)
  - [3.5. Analytics system](#35-analytics-system)
    - [3.5.1. General architecture of HDFS](#351-general-architecture-of-hdfs)
    - [3.5.2. Scaling](#352-scaling)
    - [3.5.3. Data Ingestion](#353-data-ingestion)
    - [3.5.4. Analyzing](#354-analyzing)
  - [3.6. Automation process](#36-automation-process)
    - [3.6.1. Production system](#361-production-system)
    - [3.6.2. Analytics system](#362-analytics-system)


# 1. Introduction
The project is aiming to do a web application for Kindle book reviews and a system to analyze the statistics. An automation script to set up the whole system is also required.

This repository contains the necessary code to run this web application and analytics system plus an automation script which sets up the whole system automatically.

## 1.1. Instances
We need several AWS instances to run the system.
- Front end
  - Web server
  - MySQL server
  - MongoDB server

- Hadoop cluster
  - Namenode
  - Datanode1
  - Datanode2
  - Datanode3
  - ...

## 1.2. File structure and role

There are some template files and some values such as IP and hostname need to be changed to set up the whole system. **Note that this will be AUTOMATICALLY DONE by automation script which is `g15automation.py`**, you don't need to worry about this.

<details><summary>Click to expand</summary>

- analytics_template
  - `pearson_correlation.py`
    
    A python script to calculate Pearson correlation between review length and book price.
  - `tfidf.py`
    
    A python script to calculate TF-IDF values of words in review texts.
- frontend_template
  - `comm_db.py`
    
    A python script to serve as a middleware between web application and databases.
  - `config.py`

    A **template** configuration file to store database connection details such as IP, port and password.
  - `index.html`
    
    Front end HTML file which determines the structure of the web page.
  - `main.css`
    
    Front end cascading style sheet which decorates the web page.
  - `main.js`
    
    A **template** JavaScript file which determines the interaction logic of the front end.
  - `web.bash`
    
    A shell script to set up web server.
  - `nginxdefault`

    An Nginx configuration to configure web server and a reverse proxy for the middleware.
  - `axios.min.js`
    
    Necessary JavaScript library.
  - `style.css`
  - `vue.js`

    Necessary JavaScript library.
  - `vxe-table.js`

    Necessary JavaScript library.
  - `xe-utils.js`

    Necessary JavaScript library.

- hadoop_template
  - `namenode.bash`

    A **template** shell script to set up namenode.
  - `datanode.bash`

    A **template** shell script to set up datanode.
  - `analytics.bash`

    A **template** shell script to start HDFS system, inject the data and run analytics python code.
- mongo
  - `mongo.bash`

    A shell script to set up MongoDB server and import data to MongoDB.
  - `mongo_commands.js`

    A MongoDB script to create database structure and users.
  - `kindle_metadata_final.zip`

    Kindle books metadata.
- mysql
  - `mysql.bash`

    A shell script to set up MySQL server.
  - `sql_commands.sql`

    A MySQL script to create database structure, create users and import data to MySQL.
- `g15_config.py`
    
    A confiuration file to store some parameters such as IMAGEID.
- `g15automation.py`

    An automation script to set up the whole system.
- `README.md`
- `.gitignore`

</details>


## 1.3. Web application features

### 1.3.1. Search
Users can search books by title in the top bar of the home page. The searching result of the related book information(title, image, category, description and price) will show in a list.

### 1.3.2. Pagination
If there are more than 50 results, the page will only show the first 50 results. You can click `next page` button located on the top to view the next 50 results.

### 1.3.3. Add a new book
User can add a new book at the homepage by manually input book attributes(eg. ASIN number, title, imUrl and description) to the database in the top bar of the home page.

### 1.3.4. Add a new review
After users arrive at the search result page, they can click a book title and add a new review manually at the pop-up window to the database.

### 1.3.5. Sort book by genre
After you perform a search and get some results, you can click a genre in category column and the page will show the results in this genre.

### 1.3.6. Reviews sort by time
Users can sort reviews by time at the pop-up view details window. They can click the `Sort by time` button to sort reviews. 

<details>
<summary>Some screenshots</summary>

![Homepage](assets/image14.png)
![Result page](assets/image6.png)
![Review page](assets/image7.png)
![Detail page & Add a review](assets/image3.png)
![Add a book](assets/image12.png)

</details>

## 1.4. Automation script features

### 1.4.1. Flexible

- You can choose to set up *web and databases* only or set up *hadoop cluster* only.
- You can choose how many datanodes you need when running the script.
- You can always **scale** the hadoop cluster by running the script without rebuilding the front end system.
- You can come back to the script anytime you want to perform tear-down process.

### 1.4.2. Prompts

The script will show you web application IP address and how to get analytics result file.


# 2. Usage

Following steps show how to run our automation script.

## 2.1. Set up environment

1. This automation script is written by Python and requires **Python 3.7** or higher to run.

2. You need to install AWS Command Line Interface to run this programme. More information about AWS CLI can be found here: [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/). Please follow the instructions to install AWS CLI on your system.

3. You also need run the following code to install some necessary modules.

    ```
    python3 -m pip install boto3 --user
    python3 -m pip install paramiko --user
    ```


## 2.2. Set up credentials
To run the automation process, you first need to put your AWS credentials in `g15_config.py`, `CRED` variable. Please make sure the credentials are in tripple quotes.

The credentials will be something like:
```
aws_access_key_id=ASIAQ6R4KCM7547T6YGH
aws_secret_access_key=ak0Xmj1zmYB5+9a8rca8LPbS5Owmp6SmIEMpwSFp
aws_session_token=FwoGZXIvYXdzEHQaDOHqdRmYfE1fKPbuqiLOAY6ng/nu7PxxEC6moRopnfY2NMBuy2Ru2ZapKs5Ur44zAk9MFGmZ9hiSBJSLirR66cTMxhyKh9px22budnmCNw/LQzV9n45lWnNq9RcC1koECTy/886zuvATZrW95hpFaXj47qw09bDogfYzLOlAxuaLuRjs+RVSsFu92KczItXpAPzulRhuo5Ux/rF+WDhCVVvySJdG9FZ2C41YWUL6jloXa9jtcqF/nQfNh1zP5pkDC8QBYttpn9GLNrgchHsnF641vM77akCGfex6ved7KODPrf4FMi1kGqKxgoRaz04DTK+AySNF2uytfEouBJ4vnM76qxUmNeyJHHjnZCFoDuNKizA=
```

You can also customize your preferred `IMAGEID` in `g15_config.py`.

## 2.3. Automate it !
After finishing setting the credentials, you can directly run `g15automation.py` to automatically set up the whole system.

There are some simple prompts in the process of running and you may need to answer *yes/no* or *input* some numbers for some prompts.

<br>

<details>
<summary>Some prompts</summary>

### 2.3.1. Setting up WEB and database
A prompt will ask you:
```
Setup WEB and Database?
(1) Yes (2) No
```

- Yes, the programme will set up WEB frontend instance, MySQL instance and MongoDB instance.
- No, skip this setup.

### 2.3.2. Setting up Hadoop cluster
A prompt will ask you:
```
Setup Hadoop cluster?
(1) Yes (2) No
```

- Yes, the programme will ask you how many datanodes you need and you shall input a number. And it will set up one namenode instance plus your desired number of datanode instances.
```
Please input how many datanodes you want to setup.
```
- No, skip this setup.

### 2.3.3. Clean up
A prompt will ask you:
```
Tear down everything?
(1) Yes (2) No
```

- Yes, the programme will terminate the instances it created so far and delete security groups it has created.
- No, skip this process.
</details>


## 2.4. Note
1. It is not necessary that you run the clean process after setting up. You can always re-running this script with skipping the setup process (by choosing *no*) to reach the cleanup process.
2. After setting up, you can easily scale up and down the Hadoop cluster by re-running this script with skipping **WEB and database** process and inputting your desired number of datanodes. The script will automatically **delete** the old cluster and build a new one. **NOTE: Please BACKUP your cluster BEFORE you scale up and down, the script WILL NOT keep your data**

# 3. Design

## 3.1. Front end

Front end consist of two parts, web and middleware.

The shell script `web.bash` will automatically install Nginx, Python3.7 and Python modules. Then it will start up a web server and middleware.

### 3.1.1. Web

We use a progressive framework Vue for building Web user interfaces. It is designed from the ground up to be incrementally adoptable and easy to pick up and integrate with other libraries or existing projects.The Web Application files are stored in the frontend_template folder on github.

[Vue.js project website](https://vuejs.org/)

### 3.1.2. Middleware
There is also a middleware between our web application and databases as it is not wise for the front end to communicate with databases directly. For this middleware, we use a Python module `FastApi` as a server to get requests and return responses. This `FastApi` also writes web logs to MongoDB server. We also use Python module `pymongo` and `SQLAlchemy` to perform queries on the database. Finally, we use **Nginx** to serve the front end HTML, CSS and JS code and make a reverse proxy to our middleware.

## 3.2. Database

The backend of the production system consists of two standalone AWS ec2 instances to host relational database and non-relational database separately. Database setup is accomplished with Bash, Mysql and Mongo scripts.

### 3.2.1. MySQL

- Relational Database (hosted on a standalone AWS ec2 instance)
- Mysql is chosen to store relational data, and the automation is accomplished through a combination of Mysql setup bash script and SQL commands scripts.
- Bash script, which is `mysql.bash`, performs the following functionalities:
  1. Install Mysql database
  2. Create root user and test user with corresponding passwords
  3. Configure Mysql network to allow remote connection
  4. Execute Mysql commands script 


- SQL commands script which is `sql_commands.sql`, performs the following functionalities:
  1. Create kindle_reviews database 
  2. Create table reviews to store kindle reviews with adding indexes to speed up performance
  3. Load kindle reviews data into table

## 3.3. MongoDB

- Mongodb (hosted on a standalone AWS ec2 instance)
- Mongodb is chosen to store non-relational data (kindle book metadata), and the automation is accomplished through a combination of Mongodb setup bash script and mongo commands
- Bash script, which is `mongo.bash`, performs the following functionalities: 
  1. Install Mongodb database
  2. Configure Mysql network to allow remote connection
  3. Unzip kindle metadata and execute mongo commands
  4. Load kindle metadata into Mongodb Collection

- Mongo commands script which is `mongo_commands.js`, performs the following functionalities:
  1. Create admin user against admin database with secure password
  2. Create kindle_metadata database and collection to store metadata with assigned test_user and password to it
  3. Create web_log database and collection to store web logs with assigned test_user and password to it

## 3.4. Data Processing
- The kindle metadata is processed and cleaned to remove records which miss major information such as `asin`, `title`, etc
- The final version of kindle metadata is exported and stored separately as a zip file `kindle_metadata_final.zip` for the usage of automation.

## 3.5. Analytics system

### 3.5.1. General architecture of HDFS

We set up a multi-node cluster with Hadoop 3.3.0 and Spark 3.0.1. Our HDFS architecture contains one master(namenode) and 3 workers(datanode), you can also choose how many datanodes you want in the processing of running automation script.

HDFS is used to store the data, Spark is used to perform analytics tasks:
1. calculation of Pearson Correlation between the book price and the average review length.
2. calculation of TF-IDF of each word in each review

### 3.5.2. Scaling

For now, the automation script can scale up and down the cluster by **destroying** the whole cluster then **rebuilding** it.

### 3.5.3. Data Ingestion 
- From Mongodb to HDFS

    Connect the name node to the MongoDB server by mongoexport, import kindle_metadata.json to localhost and put the file into HDFS.

- From RDBMs to HDFS

    Connect the name node to the SQL server by sqoop, import kindle_reviews.csv to HDFS directly.

### 3.5.4. Analyzing

1. Pearson correlation
   - Put kind_metadata.json to HDFS
   - Initialize a pyspark session in spark context
   - Read kindle_metadata.json and kindle_reviews.csv as pyspark.sql.Dataframe
   - Preprocess kindle_metadata.json including selecting columns `asin` and `price` and filtering books without price information given.
   - Preprocess kindle_reviews.csv including selecting columns `asin` and `reviewText`,  creating new column storing the length of each review, grouping the dataframe by `asin` and do aggregations with `mean` methods.
   - Assume x, y represents the price of the book and the average review length respectively, pearson correlation is calculated as
        
        <img src="https://latex.codecogs.com/svg.latex?\dfrac{n\sum{xy}-\sum{x}\sum{y}}{\sqrt{n\sum{x^2}-(\sum{x})^2}\sqrt{n\sum{y^2}-(\sum{y})^2}}" />
        
        where n is the total number of books.
    - We then calculate each term in map-reduce fashion. For example, we apply Map function to calculate <img src="https://latex.codecogs.com/svg.latex?x_iy_i" /> and apply the Reduce function to sum them up to get <img src="https://latex.codecogs.com/svg.latex?xy" />.
    - **Result**

        The resulting pearson correlation score is -0.025, meaning there is barely no relationship between the price of a book and its average review length.

2. Calculating TF-IDF

- Initialize a pyspark session in spark context.
- Read the `kindle_reviews.csv` as `Pyspark.sql.Dataframe`.
- Preprocessing `kindle_reviews.csv` including filter the rows without any review text and selecting columns `asin` and `reviewText`.
- Apply Tokenizer to separate each word for each review, store the result in the column `Words`.
- Apply Countvectorizer to fit and transform the new table to get the number of occurrence of each word, store the result in the column `raw_features`.
- Apply build-in library IDF to get the tf-idf value, store the result in the column `tfidf_value`.
- Reorganize the output Dataframe in map-reduce fashion, apply Map function to map the word in vocabulary to its corresponding TF-IDF value.

## 3.6. Automation process

The image shows how our automation script runs.

![](assets/image9.png)


### 3.6.1. Production system

Setup cloud infrastructures using python script `g15automation.py`. The script leverages multiple libraries and will perform following functionalities: 
- Initialize aws session,  ec2 client and ec2 resource.
- Create ssh key for ec2 instances.
- Create and configure security groups.
- Create three ec2 instances for hosting web server, MySQL database, MongoDB database separately.
- Remote execute commands in the three newly created instances to setup web server, MySQL database and MongoDB database.


### 3.6.2. Analytics system

- Initialize aws session, ec2 client and ec2 resource.
- Create ssh key for ec2 instances.
- Create and configure security groups.
- Create four ec2 instances for one namenode and three datanodes.
- Setting up a multi-node cluster in hadoop 3.3.0 in a distributed Hadoop environment.
- Setting up Sqoop and MongoDB at namenode to load data from the production system (MySQL and MongoDB), and store it in the hadoop distributed file system.
- Setting up Apache Spark framework for analyzing metadata and reviews in cluster computing environments.
- Initializing spark session and Call `tfidf.py` and `pearson_correlation.py` to calculate TF-IDF on the review text and Pearson Correlation between price and average review length. We store TF-IDF value in several CSV files in `reviews_tfidf_dir` directory.
- Stop spark session

