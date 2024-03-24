# Code for ETL operations on Country-GDP data
"""
table attr (extraction): Name, MC_USD_Billion
table attr (final): Name, MC_USD_Billion, MC_GBP_Billion, MC_EUR_Billion, MC_INR_Billion

"""
list_of_largest_banks_url = "https://web.archive.org/web/20230908091635/https://en.wikipedia.org/wiki/List_of_largest_banks"
attrs_extraction = ['Name', 'MC_USD_Billion']
output_path = "./Largest_banks_data.csv"
csv_path = "./exchange_rate.csv"
db_name = 'Banks.db'
table_name = 'Largest_banks'
log_file = "code_log.txt"

# Importing the required libraries
import requests
from bs4 import BeautifulSoup
import pandas as pd
import numpy as np
import sqlite3
import numpy
import datetime as dt


def log_progress(message):
    ''' This function logs the mentioned message of a given stage of the
    code execution to a log file. Function returns nothing'''
    timestampFormat = "%Y-%h-%d-%H:%M:%S"
    
    with open(log_file, 'a') as file:
        file.write(f"{dt.datetime.now().strftime(timestampFormat)} : {message}\n")


def extract(url, table_attribs):
    ''' This function aims to extract the required
    information from the website and save it to a data frame. The
    function returns the data frame for further processing. '''
    
    res = requests.get(url)
    data = BeautifulSoup(res.text, 'html.parser')
    table = data.find_all('tbody')[0]
    rows = table.find_all('tr')
    
    extracted_data = []
    for row in rows:
        cols = row.find_all('td')
        
        if len(cols) != 0:
            bank_name = cols[1].text.strip()
            market_cap = float(cols[-1].text.strip())
            extracted_data.append((bank_name, market_cap))

    df = pd.DataFrame(columns=table_attribs, data=extracted_data)
    
    return df


def transform(df, csv_path):
    ''' This function accesses the CSV file for exchange rate
    information, and adds three columns to the data frame, each
    containing the transformed version of Market Cap column to
    respective currencies'''
    
    # get exchange rate details
    exchange_rate_df = pd.read_csv(csv_path)
    exchange_rate_dict = exchange_rate_df.set_index('Currency').to_dict()['Rate']

    # add columns
    df['MC_GBP_Billion'] = [np.round(x * exchange_rate_dict['GBP'], 2) for x in df['MC_USD_Billion']]
    df['MC_EUR_Billion'] = [np.round(x * exchange_rate_dict['EUR'], 2) for x in df['MC_USD_Billion']]
    df['MC_INR_Billion'] = [np.round(x * exchange_rate_dict['INR'], 2) for x in df['MC_USD_Billion']]

    return df


def load_to_csv(df, output_path):
    ''' This function saves the final data frame as a CSV file in
    the provided path. Function returns nothing.'''
    df.to_csv(output_path)


def load_to_db(df, sql_connection, table_name):
    ''' This function saves the final data frame to a database
    table with the provided name. Function returns nothing.'''

    df.to_sql(
        table_name,
        sql_connection,
        if_exists='replace',
        index=False
    )

def run_query(query_statement, sql_connection):
    ''' This function runs the query on the database table and
    prints the output on the terminal. Function returns nothing. '''

    query_output = pd.read_sql(query_statement, sql_connection)
    print(query_output)


''' Here, you define the required entities and call the relevant
functions in the correct order to complete the project. Note that this
portion is not inside any function.'''


if __name__ == "__main__":
    # Declaring known values
    log_progress("Preliminaries complete. Initiating ETL process")

    # Call extract() function
    df = extract(list_of_largest_banks_url, attrs_extraction)
    log_progress("Data extraction complete. Initiating Transformation process")
    # print(df)

    # Call transform() function
    df_with_exchange_rate = transform(df, csv_path)
    log_progress("Data transformation complete. Initiating Loading process")
    # print(df_with_exchange_rate)

    # Call load_to_csv()
    load_to_csv(df_with_exchange_rate, output_path)
    log_progress("Data saved to CSV file")
    
    # Initiate SQLite3 connection
    sql_connection = sqlite3.connect(db_name)
    log_progress("SQL Connection initiated")
    
    # Call load_to_db()
    load_to_db(df_with_exchange_rate, sql_connection, table_name)
    log_progress("Data loaded to Database as a table, Executing queries")
    
    # Call run_query()
    run_query("SELECT * FROM Largest_banks", sql_connection)
    run_query("SELECT AVG(MC_GBP_Billion) FROM Largest_banks", sql_connection)
    run_query("SELECT Name from Largest_banks LIMIT 5", sql_connection)
    log_progress("Process Complete")
    
    # Close SQLite3 connection
    sql_connection.close()
    log_progress("Server Connection closed")