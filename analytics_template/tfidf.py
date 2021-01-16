from pyspark.sql import SparkSession
from pyspark.ml.feature import IDF, Tokenizer, CountVectorizer

sparkSession = SparkSession.builder.appName("tf idf Notebook").getOrCreate()
sc = sparkSession.sparkContext
hdfs_nn = "[[namenodepriip]]"
reviews = sparkSession.read.csv("hdfs://%s:9000/user/hadoop/Reviews/part-m-00000" % (hdfs_nn))

reviews = reviews.filter(reviews._c5.isNotNull()).select("_c1","_c5") #982597

#Use tokenizer to seperate each word for each sentences
tokenizer_word = Tokenizer(inputCol="_c5", outputCol="Words")
#After tokenizer, we added one col(Words to table) 
words_Data = tokenizer_word.transform(reviews)
# words_Data.show(5)
#Count the number of words
countvectorizer = CountVectorizer(inputCol="Words", outputCol="raw_features")
model = countvectorizer.fit(words_Data)
#Add count to our table
get_count_data = model.transform(words_Data)
#get_count_data.show(5)
#calculate TF-IDF 
idf_value = IDF(inputCol="raw_features", outputCol="tfidf_value")
idf_model = idf_value.fit(get_count_data)
final_rescaled_data = idf_model.transform(get_count_data)
#final_rescaled_data.show(5)
final_rescaled_data.select("tfidf_value").show()
#vocabulary list
vocabalary = model.vocabulary

#Calculate TF-IDF 
def extract(value):
    return {vocabalary[i]: float(tfidf_value) for (i, tfidf_value) in zip(value.indices, value.values)}

def save_as_string(value):
    words = ""
    for (i, tfidf_value) in zip(value.indices, value.values):
        temp_value = vocabalary[i] + ":" + str(float(tfidf_value)) + ", "
        words += temp_value
    return words[:-2]

output_file = final_rescaled_data.select('_c1','_c5', 'tfidf_value').rdd.map(
    lambda x: [x[0], x[1], save_as_string(x[2])])

output_df = sparkSession.createDataFrame(output_file,['asin','reviewText', 'tfidf_value'])
output_df.show()
output_df.write.csv("hdfs://%s:9000/output/reviews_tfidf_dir" % (hdfs_nn))
sc.stop()
