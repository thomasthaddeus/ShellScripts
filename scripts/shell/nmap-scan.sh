ports=$(nmap -p- --min-rate=1000  -T4 $1 | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)

nmap -sC -sV -p$ports $1
