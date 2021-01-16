from fastapi import FastAPI, Request
from sqlalchemy import Column, VARCHAR, TEXT,CHAR, create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.sql.sqltypes import INT
import pymongo
from config import *
from urllib.parse import unquote
import logging
import time


Base = declarative_base()
# define a Review object
class Review(Base):
    # table name
    __tablename__ = MYSQL_TABLE
    # structure
    idx = Column(INT, primary_key=True)
    asin = Column(CHAR(10))
    helpful = Column(TEXT)
    overall = Column(INT)
    review = Column(VARCHAR(8000))
    reviewTime = Column(TEXT)
    reviewerID = Column(TEXT)
    reviewerName = Column(TEXT)
    summary = Column(TEXT)
    unixReviewTime = Column(TEXT)


# init mysql connection
# engine = create_engine('mysql+pymysql://root:jrKa2qZhpt-Easd3GGV97@localhost:3306/kindle_review')
engine = create_engine(f'mysql+pymysql://{MYSQL_USERNAME}:{MYSQL_PASSWORD}@{MYSQL_IP}:{MYSQL_PORT}/{MYSQL_DATABASE}')
DBSession = sessionmaker(bind=engine)

# init mongodb
# Search for existing book by author and by title.
mongodb = pymongo.MongoClient(f"mongodb://{MONGODB_USERNAME}:{MONGODB_PASSWORD}@{MONGODB_IP}/?authSource={MONGODB_COLLOC}&authMechanism=SCRAM-SHA-256")
mongodb_db = mongodb["kindle_metadata"]
mongodb_col = mongodb_db["kindle_metadata"]

web_log = mongodb["web_logs"]
web_log_col = web_log["web_logs"]


app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    response = await call_next(request)
    # print(f"{time.time()}|{request.method}|{request.url.path}|{response.status_code}")
    temp = []
    temp.append(time.time())
    temp.append(request.method)
    temp.append(str(request.url.include_query_params()))
    temp.append(response.status_code)
    web_log_col.insert({'timestamp':temp[0],'method':temp[1],'path':temp[2],'status_code':temp[3]})
    temp = []
    return response


def mongo_fetch_all(cur):
    result = []
    result.append(cur.count())
    for i in cur:
        result.append(i)
    return result

@app.get("/api/readreview/")
def read_review(asin: str='', reviewerID:str='',sortby:str=''):
    session = DBSession()
    if sortby == '':
        if asin and reviewerID:
            reviews = session.query(Review).filter(Review.asin == asin).filter(Review.reviewerID == reviewerID).all()
        elif asin:
            reviews = session.query(Review).filter(Review.asin == asin).all()
        else:
            reviews = session.query(Review).filter(Review.reviewerID == reviewerID).all()
        session.close()
    else:
        if asin and reviewerID:
            reviews = session.query(Review).filter(Review.asin == asin).filter(Review.reviewerID == reviewerID).order_by(Review.unixReviewTime).all()
        elif asin:
            reviews = session.query(Review).filter(Review.asin == asin).order_by(Review.unixReviewTime).all()
        else:
            reviews = session.query(Review).filter(Review.reviewerID == reviewerID).order_by(Review.unixReviewTime).all()
        session.close()
    return reviews

@app.get("/api/addreview/")
def add_review(asin: str='', reviewerID:str='',content:str=''):
    session = DBSession()
    new_review = Review(asin=asin,review=content)
    session.add(new_review)
    session.flush()
    session.commit()
    session.close()
    return {'success':True}

@app.get('/api/readbook/')
def read_book(author:str='',title:str='',category='',offset:int=0,batch=50):
    if author and title:
        result = mongo_fetch_all(mongodb_col.find({'author':f'/{author}/','title':f'/{title}/'},{'_id':0},skip=offset,limit=batch))
    elif author:
        result = mongo_fetch_all(mongodb_col.find({'author':f'/{author}/'},{'_id':0},skip=offset,limit=batch))
    elif category:
        category = unquote(category)
        result = mongo_fetch_all(mongodb_col.find({'categories':{'$elemMatch':{'$elemMatch':{'$in':[f'{category}']}}}},{'_id':0},skip=offset,limit=batch))
    else:
        result = mongo_fetch_all(mongodb_col.find({'title':{'$regex': f".*{title}.*", '$options': 'i'}},{'_id':0},skip=offset,limit=batch))
    return result

@app.get('/api/addbook/')
def add_book(author:str='',title:str='',asin:str='',description:str='',imUrl:str='',price:str=''):
    mongodb_col.insert({'title':title,'asin':asin,'description':description,'imUrl':imUrl,'price':price})
    return {'success':True}

