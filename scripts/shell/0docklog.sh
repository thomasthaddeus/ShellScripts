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

# Set colors for easier reading
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Look for lines containing "error" or "exception", ignoring case, and count the occurrence of each unique error message
echo -e "${RED}Errors and Exceptions:${NC}"
grep -i -e "error" -e "exception" "$LOGFILE" | sort | uniq -c
echo

# Search for "warning" or "warn" to find warning messages
echo -e "${YELLOW}Warnings:${NC}"
grep -i -e "warn" "$LOGFILE" | sort | uniq -c
echo

# Finding entries related to specific services
echo -e "${BLUE}Backend Entries:${NC}"
grep -i "com.docker.backend.exe" "$LOGFILE"
echo

# Checking Start and Stop Times
echo -e "${GREEN}Start and Stop Times:${NC}"
grep -i -e "Docker started" -e "Docker stopped" "$LOGFILE"
echo

# Counting the number of entries per day
echo -e "${CYAN}Entries per Day:${NC}"
cut -d"[" -f2 "$LOGFILE" | cut -d"T" -f1 | uniq -c
echo
