import pandas as pd
import sqlite3

# wget https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMSkillsNetwork-PY0221EN-Coursera/labs/v2/INSTRUCTOR.csv

conn = sqlite3.connect('STAFF.db')
tableName = 'INSTRUCTOR'
attrList = ['ID', 'FNAME', 'LNAME', 'CITY', 'CCODE']
filePath = '/home/project/INSTRUCTOR.csv'

df = pd.read_csv(filePath, names = attrList)
df.to_sql(tableName, conn, if_exists='replace', index=False)
print('Table is ready')

query_statement = f"SELECT * FROM {tableName}"
query_output = pd.read_sql(query_statement, conn)
print(query_statement)
print(query_output)

query_statement = f"SELECT FNAME FROM {tableName}"
query_output = pd.read_sql(query_statement, conn)
print(query_statement)
print(query_output)

query_statement = f"SELECT COUNT(*) FROM {tableName}"
query_output = pd.read_sql(query_statement, conn)
print(query_statement)
print(query_output)

dataDict = {
    'ID': [100],
    'FNAME': ['John'],
    'LNAME': ['Doe'],
    'CITY': ['Paris'],
    'CCODE': ['FR']
}
dataAppend = pd.DataFrame(dataDict)
dataAppend.to_sql(tableName, conn, if_exists='append', index=False)
print('Data appended successfully')

query_statement = f"SELECT COUNT(*) FROM {tableName}"
query_output = pd.read_sql(query_statement, conn)
print(query_statement)
print(query_output)

conn.close()

# https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMSkillsNetwork-PY0221EN-Coursera/labs/v2/Departments.csv