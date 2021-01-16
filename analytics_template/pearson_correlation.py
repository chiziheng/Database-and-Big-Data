from pyspark.sql import SparkSession
from pyspark.sql.functions import udf
from pyspark.sql.types import IntegerType
import math

class PearsonCorrelationCompute:
    def __init__(self):
        self.spark_session = SparkSession.builder.appName("Pearson Correlation Computation").getOrCreate()
        self.price_review_avglen_rdd = None
        self.score = 0.0
        
    def get_pearson_correlation(self, metadata_path, reviews_path):
        price_cleaned = self.get_price(metadata_path)
        # price_cleaned.show()
        kindle_avg_len = self.get_avg_len_reviews(reviews_path)
        kindle_avg_len = kindle_avg_len.withColumnRenamed('_c1','asin')
        # kindle_avg_len.show()
        self.price_review_avglen_rdd = price_cleaned.join(kindle_avg_len,'asin').rdd
        # self.price_review_avglen_rdd.show()
        self.score = self.cal_pearson_correlation()
        self.spark_session.stop()
        return self.score
        
    def get_price(self, metadata_path):
        metadata = self.spark_session.read.json(metadata_path)
        price_raw = metadata.select("asin","price")
        price_cleaned = price_raw.filter(price_raw.price.isNotNull())
        return price_cleaned
        
    def get_avg_len_reviews(self, reviews_path):
        reviews = self.spark_session.read.csv(reviews_path, header=False)
        get_review_len = udf(lambda s:len(s.split(" ")) if s is not None else 0, IntegerType())
        kindle_avg_len = reviews.withColumn('review_len', get_review_len(reviews['_c5']))\
                                .select('_c1','review_len')\
                                .groupby('_c1')\
                                .agg({'review_len':'mean'})
        return kindle_avg_len
    
    def cal_pearson_correlation(self):
        n = self.price_review_avglen_rdd.count() #825
        avglen_mul_price = self.price_review_avglen_rdd.map(lambda p1: p1['price']*p1['avg(review_len)'])
        sum_avglen_mul_price = avglen_mul_price.reduce(lambda v1,v2: v1+v2) #type float
        
        avglen = self.price_review_avglen_rdd.map(lambda p2: p2['avg(review_len)'])
        sum_avglen = avglen.reduce(lambda v1,v2: v1+v2) #type float
        
        
        each_price = self.price_review_avglen_rdd.map(lambda p3: p3['price'])
        sum_price = each_price.reduce(lambda v1,v2: v1+v2) #type float
        
        avglen_square = self.price_review_avglen_rdd.map(lambda p4: p4['avg(review_len)']**2)
        sum_avglen_square = avglen_square.reduce(lambda v1,v2: v1+v2) #type float
        
        price_square = self.price_review_avglen_rdd.map(lambda p5: p5['price']**2)
        sum_price_square = price_square.reduce(lambda v1,v2: v1+v2) #type float
        
        print("sum of (average review length multiply by price): ", sum_avglen_mul_price) #101868.16660924241
        print("sum of avglen: ", sum_avglen) # 23694.682439702836
        print("sum of price: ", sum_price) #3588.3899999999994
        print("sum of avglen square: ", sum_avglen_square) #790835.2935564622
        print("sum of price square: ", sum_price_square) #35996.44490000002
        
        numerator = n*sum_avglen_mul_price-sum_avglen*sum_price
        denominator_p1 = math.sqrt(n*sum_avglen_square-sum_avglen**2)
        denominator_p2 = math.sqrt(n*sum_price_square-sum_price**2)
        self.score = numerator/(denominator_p1*denominator_p2)
        print("Pearson Correlation: ", self.score)  #0.02516420149121902
        return self.score

if __name__=="__main__":
    hdfs_nn = "[[namenodepriip]]"
    metadata_path = "hdfs://%s:9000/input/pcc/kindle_metadata.json" % (hdfs_nn)
    reviews_path  ="hdfs://%s:9000/user/hadoop/Reviews/part-m-00000" % (hdfs_nn)
    pcc = PearsonCorrelationCompute()
    pearson_correlation = pcc.get_pearson_correlation(metadata_path, reviews_path)

    with open('pearson_corr.txt', "w") as fp:
        fp.write('Pearson Correlation: ')
        fp.write(str(pearson_correlation))
        fp.write('\n')
