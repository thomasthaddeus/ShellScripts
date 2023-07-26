first_event_date=$(awk '{print $1}' log_file.txt | head -n 1)
echo "Date of the first event: $first_event_date"
