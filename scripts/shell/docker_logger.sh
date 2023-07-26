#!/bin/bash

# Path to the Docker log file
LOGFILE="$1"

# Check that the user has provided a log file path
if [[ -z "$LOGFILE" ]]; then
    echo "Please provide a log file path."
    exit 1
fi

# Check that the log file exists
if [[ ! -f "$LOGFILE" ]]; then
    echo "The file $LOGFILE does not exist."
    exit 1
fi

# Look for lines containing "error" or "exception", ignoring case, and count the occurrence of each unique error message
grep -i -e "error" -e "exception" "$LOGFILE" | sort | uniq -c

# Search for "warning" or "warn" to find warning messages
grep -i -e "warn" "$LOGFILE" > warnings.txt
sort warnings.txt | uniq -c > warning_counts.txt
cat warning_counts.txt
# rm warnings.txt warning_counts.txt

# Finding entries related to specific services
grep -i "com.docker.backend.exe" "$LOGFILE" > backend_entries.txt
cat backend_entries.txt
# rm backend_entries.txt

# Checking Start and Stop Times
grep -i -e "Docker started" -e "Docker stopped" "$LOGFILE" > start_stop_times.txt
cat start_stop_times.txt
# rm start_stop_times.txt

# Counting the number of entries per day
cut -d"[" -f2 "$LOGFILE" | cut -d"T" -f1 | uniq -c > entries_per_day.txt
cat entries_per_day.txt
# rm entries_per_day.txt
