# Code for ETL operations on Country-GDP data
# wget https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMSkillsNetwork-PY0221EN-Coursera/labs/v2/exchange_rate.csv
"""
Task	Log message on completion
Declaring known values	Preliminaries complete. Initiating ETL process
Call extract() function	Data extraction complete. Initiating Transformation process
Call transform() function	Data transformation complete. Initiating Loading process
Call load_to_csv()	Data saved to CSV file
Initiate SQLite3 connection	SQL Connection initiated
Call load_to_db()	Data loaded to Database as a table, Executing queries
Call run_query()	Process Complete
Close SQLite3 connection	Server Connection closed
"""


# Importing the required libraries
from datetime import datetime
import sqlite3
from bs4 import BeautifulSoup
import requests
import pandas as pd
import numpy as np

log_file_path = './code_log.txt'
# log_file = "code_log.txt"
url = "https://web.archive.org/web/20230908091635/https://en.wikipedia.org/wiki/List_of_largest_banks"
# list_of_largest_banks_url = "https://web.archive.org/web/20230908091635/https://en.wikipedia.org/wiki/List_of_largest_banks"
attrs_extraction = ['Name', 'MC_USD_Billion']
output_path = "./Largest_banks_data.csv"
csv_path = './exchange_rate.csv'
# csv_path = "./exchange_rate.csv"
db_name = 'Banks.db'
table_name = 'Largest_banks'

query_1 = "SELECT * FROM Largest_banks"
query_2 = "SELECT AVG(MC_GBP_Billion) FROM Largest_banks"
query_3 = "SELECT Name from Largest_banks LIMIT 5"


def log_progress(message):
    ''' This function logs the mentioned message of a given stage of the
    code execution to a log file. Function returns nothing'''
    timestamp = datetime.now().strftime("%Y-%h-%d-%H:%M:%S")

    with open(log_file_path, 'a') as file:
        file.write(f"{timestamp}: {message}\n")


def extract(url, table_attribs):
    ''' This function aims to extract the required
    information from the website and save it to a data frame. The
    function returns the data frame for further processing. '''

    # TODO: will clean up later
    res = requests.get(url)
    data = BeautifulSoup(res.text, "html.parser")
    content = data.find_all('tbody')
    rows = content[0].find_all('tr')

    details = []
    for row in rows:
        cols = row.find_all('td') # turn this into a list
        if len(cols) != 0: # remove first row
            # bank_name = cols[1].text.strip()
            bank_name = cols[1].find_all('a')[1]['title']
            # mc = float(cols[-1].text.strip())
            mc = float(cols[2].contents[0][:-1])
            details.append((bank_name, mc))

    df = pd.DataFrame(columns=table_attribs, data=details)
    print(df)

    # log the event
    log_progress("Data extraction complete. Initiating Transformation process")

    return df


def transform(df, csv_path):
    ''' This function accesses the CSV file for exchange rate
    information, and adds three columns to the data frame, each
    containing the transformed version of Market Cap column to
    respective currencies'''

    # TODO: to be cleaned up
    # exchange = pd.read_csv('./exchange_rate.csv')
    exchange = pd.read_csv(csv_path)
    exchangeRateDict = exchange.set_index('Currency').to_dict()['Rate'] # {'EUR': 0.93, 'GBP': 0.8, 'INR': 82.95}

    # get df
    df = extract(url, ['Name', 'MC_USD_Billion'])
    df['MC_GBP_Billion'] = [np.round(x * exchangeRateDict['GBP'], 2) for x in df['MC_USD_Billion']]
    df['MC_EUR_Billion'] = [np.round(x * exchangeRateDict['EUR'], 2) for x in df['MC_USD_Billion']]
    df['MC_INR_Billion'] = [np.round(x * exchangeRateDict['INR'], 2) for x in df['MC_USD_Billion']]
    print(df)

    #log the event
    log_progress("Data transformation complete. Initiating Loading process")

    return df


def load_to_csv(df, output_path):
    ''' This function saves the final data frame as a CSV file in
    the provided path. Function returns nothing.'''

    df.to_csv(output_path)

    # log event
    log_progress("Data saved to CSV file")


def load_to_db(df, sql_connection, table_name):
    ''' This function saves the final data frame to a database
    table with the provided name. Function returns nothing.'''

    df.to_sql(
        table_name,
        sql_connection,
        if_exists='replace',
        index=False
    )

    # log event
    log_progress("Data loaded to Database as a table, Executing queries")


def run_query(query_statement, sql_connection):
    ''' This function runs the query on the database table and
    prints the output on the terminal. Function returns nothing. '''

    ''' Here, you define the required entities and call the relevant
    functions in the correct order to complete the project. Note that this
    portion is not inside any function.'''

    query_output = pd.read_sql(query_statement, sql_connection)
    print(query_output)
    # log_progress("Process Complete")


if __name__ == "__main__":
    df = extract(url, ['Name', 'MC'])
    conn = sqlite3.connect(db_name)
    load_to_db(df, conn, 'banks')
