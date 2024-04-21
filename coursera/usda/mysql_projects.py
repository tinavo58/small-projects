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

honey = 'honey_production' # only this table has 4 fields (no Period)


def main():
    tables = [
        'yogurt_production',
        'milk_production',
        'egg_production',
        'coffee_production',
        'cheese_production'
    ]
    for table in tables:

        file = f'~/Downloads/{table}.csv'

        # read file into df
        df =  pd.read_csv(file, na_values={"Value": [" (NA)", " (D)"]})
        df = df.fillna(0)

        # extract data into list of tuples
        data  = list(df.itertuples(index=False))

        # query statement
        query = f"insert into {table} values (%s, %s, %s, %s, %s)"

        with connect(**config) as conn:

            if conn.is_connected():
                print('connected')

            with conn.cursor(buffered=True) as cur:
                cur.execute(f'truncate table {table}')

                cur.executemany(query, data)
                conn.commit()
                print('records inserted...')

                cur.execute(f'select * from {table} limit 5;')
                print(cur.fetchall())


if __name__ == "__main__":
    main()
