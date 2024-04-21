#!/usr/bin/env python3
import os
from dotenv import load_dotenv; load_dotenv()
from mysql.connector import connect
import pandas as pd

config = {
    "host": os.getenv('HOST'),
    "database": 'usda',
    "user": os.getenv('USER_'),
    "password": os.getenv('PASSWORD')
}

file = '~/Downloads/milk_production.csv'


def main():
    # read file into df
    df =  pd.read_csv(file)
    df = df.fillna(0)

    # extract data into list of tuples
    data  = list(df.itertuples(index=False))

    # query statement
    query = "insert into milk_prod values (%s, %s, %s, %s, %s)"

    with connect(**config) as conn:

        if conn.is_connected():
            print('connected')

        with conn.cursor(buffered=True) as cur:

            cur.executemany(query, data)
            conn.commit()
            print('records inserted...')

            cur.execute('select * from milk_prod limit 5;')
            print(cur.fetchall())


if __name__ == "__main__":
    main()
