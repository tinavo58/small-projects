#!/bin/bash

echo -n "Enter a random number: "
read number

calc=$(($number%2))

if [[ $calc == 0 ]]
then
    echo "$number is an even number"
else
    echo "$number is an odd number"
fi
