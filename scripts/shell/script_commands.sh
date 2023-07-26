#Hello World
nano HelloWorld.sh
bash HelloWorld.sh Thaddeus Thomas

#Test Print
nano TestPrintf.sh
bash TestPrintf.sh

#stdotp
printf “%s\n” “My text in the file” > test
cat test
read content < test
echo $content


top -n 1 | tee result
# You Will see the result from top command
clear
cat result
lsResult=$(ls)
# We are saving the ls command’s output to the lsResult variable
echo $lsResult