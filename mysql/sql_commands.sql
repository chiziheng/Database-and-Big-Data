CREATE DATABASE IF NOT EXISTS kindle_reviews;
USE kindle_reviews;

DROP TABLE IF EXISTS Reviews;
CREATE TABLE Reviews(
    idx INT NOT NULL AUTO_INCREMENT, 
    asin CHAR(10) NOT NULL,
    helpful varchar(500),
    overall INT,
    review VARCHAR(8000),
    reviewTime varchar(500),
    reviewerID varchar(500),
    reviewerName varchar(500),
    summary varchar(500),
    unixReviewTime varchar(500),
	PRIMARY KEY (idx)
);
create index asin_idx on Reviews(asin);

load data local infile 'kindle_reviews.csv' 
into table Reviews
fields terminated by ',' 
enclosed by '"' 
escaped by '"' 
lines terminated by '\n'
ignore 1 lines;
