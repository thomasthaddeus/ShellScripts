#!/bin/bash
echo -n "Logins since "
who /var/log/wtmp | head -1 | awk '{print $3}'
echo "======================="

for user in `ls /home`
do
  echo -n "$user\t"
  last $user | wc -l
done
