distinct_uids=$(awk '{print $4}' log_file.txt | sort -u | wc -l)
echo "Distinct uids: $distinct_uids"
