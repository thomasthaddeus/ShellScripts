#! /bin/bash
printf "How many pizzas do you want to buy?\n"
read amount.to

if (( amount <=  0 ))
then
    printf "Please enter a number that is greater than 0.\n"
elif (( amount > 10 ))
then 
    printf "Sorry, we do not have that many pizzas.\n"
    exit 1
else
    printf "There you go. Here are %d pizzas for you.\n" "$amount"
fi