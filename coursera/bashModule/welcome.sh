#!/bin/zsh
# name=tina

# getting name input
echo -n "Enter your name: " # -n will keep the input stayed on the same line
read name # this will save the input into var `name`

# the below would printout UPPER CASE
echo $name | tr "[a-z]" "[A-Z]"
