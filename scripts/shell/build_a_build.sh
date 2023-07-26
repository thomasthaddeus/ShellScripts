#!/bin/bash
# version = ## 1.1.1
echo "Welcome to my script"
firstline=$(head -n 1 source/changelog.md)
read -a splitfirstline <<< $firstline
version=${splitfirstline[1]}
echo "You are building version" $version
echo 'Do you want to continue? (enter "1" for yes, "0" for no)'
read versioncontinue

## 
if [ $versioncontinue -eq 1 ]
  then
    echo "OK"
  else
    echo "Please come back when you are ready"
  fi

  for filename in source/*
  do
    echo $filename
  done

  if [ "$filename" == "source/secretinfo.md" ]
  then
    echo "Not copying" $filename
  else
    echo "Copying" $filename
  fi

  ## 
  if [ "$filename" == "source/secretinfo.md" ]
  then
    echo "Not copying" $filename
  else
    echo "Copying" $filename
    cp $filename build/.
  fi


## 
cd build/
# We'll add more code here later
cd ..

echo "Build version $version contains:"
ls