read_discrete_errors=$(grep "192.168.88.60" log_file.txt | grep -c "READ_DISCRETE_INPUTS_EXCEPTION" log_file.txt)
echo "READ_DISCRETE_INPUTS_EXCEPTION errors from 192.168.88.60: $read_discrete_errors"
