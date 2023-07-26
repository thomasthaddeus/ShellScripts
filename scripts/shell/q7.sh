unique_pairs=$(awk '{print $2, $3}' log_file.txt | sort -u | wc -l)
echo "Unique source IP / dest IP pairs: $unique_pairs"
