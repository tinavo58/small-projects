import mysql.connector
from dotenv import load_dotenv; load_dotenv()
import requests
from bs4 import BeautifulSoup
import random
import os

HOST = os.getenv('HOST')
USER_ROOT = os.getenv('USER_ROOT')
PASSWORD = os.getenv('PASSWORD')
DATABASE='Little_Lemon'

STARTER_TYPES = ['Vietnamese', 'Chinese', 'Thai', 'Malaysian']


def getPrice():
    price = 0
    while (price < 5) or (price > 10):
        price = random.random() * 10

    return round(price, 2)


def connectDB(db):
    try:
        mydb = mysql.connector.connect(
            host=HOST,
            user=USER_ROOT,
            passwd=PASSWORD,
            database=db
        )
    except Exception as e:
        print(e)
        return
    else:
        return mydb


def extractStartersList():
    url = "https://www.taste.com.au/recipes/collections/top-50-starters"
    res = requests.get(url)

    soup = BeautifulSoup(res.text, 'html.parser')
    foodsData = soup.find_all('h3')

    return [item.find('a').text for item in foodsData]


def generateStartersList():
    starters = extractStartersList()
    return [(each, getPrice(), random.choice(STARTER_TYPES)) for each in starters]


if __name__ == "__main__":
    mydb = connectDB(DATABASE)

    if mydb is not None:
        cur = mydb.cursor()

        cur.executemany(
            "INSERT INTO Starters VALUES (%s, %s, %s)",
            generateStartersList()
        )

        cur.execute(
            "SELECT * FROM Starters"
        )

        results = cur.fetchall()

        mydb.commit()
        mydb.close()

    print(results)
