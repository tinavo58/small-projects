#!/bin/bash

wget https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBM-LX0117EN-SkillsNetwork/labs/M3/L2/arrays_table.csv

csvFile="./arrays_table.csv"

column1=($(cut -d "," -f1 $csvFile))
column2=($(cut -d "," -f2 $csvFile))
column3=($(cut -d "," -f3 $csvFile))

echo "Display the first column:"
echo "${column1[@]}"
echo ""

echo "Display the second column:"
echo "${column2[@]}"
echo ""

echo "Display the third column:"
echo "${column3[@]}"


## create new array
# initialize array with header
newCol=("diff_col")

# get the number of lines
noOfLines=$(cat $csvFile | wc -l)
echo "There are $noOfLines lines in the csv file downloaded"

# populate the array
for ((i=1; i<$noOfLines; i++)); do
    newCol[$i]=$((column3[$i] - column2[$i]))
done
echo "${newCol[@]}"


## create report
echo "${newCol[0]}" > col_3.txt
for ((i=1; i<noOfLines; i++)); do
    echo "${newCol[$i]}" >> col_3.txt
done

paste -d "," $csvFile col_3.txt > report.csv
