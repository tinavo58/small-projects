#!/bin/bash
echo -n "Enter first number: "
read num1

echo -n "Enter second number: "
read num2

total=$((num1+num2))
echo "The sum of $num1 and $num2 is $total"

product=$((num1*num2))
echo "The product of $num1 and $num2 is $product"


if [[ $total -lt $product ]]
then
    echo "The sum is less than the product"
elif [[ $total == $product ]]
then
    echo "The sum is equal to the product"
elif [[ $total -gt $product ]]
then
    echo "The sum is greater than the product"
fi
