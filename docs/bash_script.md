# Commands

```bash
env
echo $HISTSIZE
export HISTSIZE=5
#------------------------------------------
echo 1
echo 2
echo 3
echo 4
echo 5
#------------------------------------------
sudo mkdir /scripts
sudo cp /opt/linuxplus/working_with_bash_scripts/testscript.sh /scripts/testscript.sh
testscript.sh
#------------------------------------------
echo $PATH
cd ~
sudo vim ~/.bash_profile
export PATH=$PATH:/scripts
#------------------------------------------
[ctrl + o][ enter ][ctrl + x]
source ~/.bash_profile
echo $PATH
```

## `testscript.sh`

```bash
#------------------------------------------
lastlog | tail -n +2 | sort -k1
.bashrc
alias ulog='lastlog | tail -n +2 | sort -k1'
source .bashrc
ulog

sudo touch /scripts/check_storage.sh
sudo chown student01 /scripts/check_storage.sh
chmod 755 /scripts/check_storage.sh
#------------------------------------------
Applications -> Accessories -> Text Editor
Open -> Other Documents
check_storage.sh
Ln 1, Col 1
#------------------------------------------
```

## Beginning of script

```bash
#!/bin/bash
echo "Beginning storage check..."
exec >> ~/storage_report.txt
echo "Date: $(date)"
echo "------------------"
part=/dev/sdal
checkper=$(df -h | grep $part | awk '{print $5}' | cut -d '%' -f1)
echo "$part is $checkper% full."
echo "Storage check complete. Report saved to storage_report.txt." >&2

SAVE
```

## Running commands

```bash
./check_storage.sh  #In the terminal
cat storage_report.txt
```
