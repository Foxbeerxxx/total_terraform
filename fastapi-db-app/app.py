from fastapi import FastAPI
import mysql.connector
import os

app = FastAPI()

db_host = os.getenv("DB_HOST")
db_user = os.getenv("DB_USER")
db_pass = os.getenv("DB_PASSWORD")
db_name = os.getenv("DB_NAME")

@app.get("/")
def root():
    conn = mysql.connector.connect(
        host=db_host, user=db_user, password=db_pass, database=db_name)
    cur = conn.cursor()
    cur.execute("SELECT NOW()")
    now = cur.fetchone()[0]
    return {"mysql_time": str(now)}
