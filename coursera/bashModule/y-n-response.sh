#!/bin/bash

echo -n "Do you love travelling? (y/n) "
read res

if [ $res == "y" ]
then
    echo "You said '$res'. Me too. I hope we can travel together one day"
elif [ $res == "n" ]
then
    echo "You said '$res'. Why not? Travelling is great; you get to experience new things"
else
    echo "Sorry! Your response does not match \"y\" or \"n\""
fi
