#!/bin/bash

ciphertext_base64="z4jvv70e77+977+977+9Fu+/vUXvv73vv73vv73vv70nRCXvv70/77+9Ue+/vWrvv73vv73xtZu/77+977+9"
ciphertext=$(echo $ciphertext_base64 | base64 --decode)

# Define the start and end Unix timestamps for January 1st, 2023
start_date="2023-01-01 00:00:00"
end_date="2023-01-02 00:00:00"
start_timestamp=$(date --date="$start_date" +%s)
end_timestamp=$(date --date="$end_date" +%s)

found_key=""
decrypted_message=""

# Iterate through all possible Unix timestamps on January 1st, 2023, and attempt decryption
for timestamp in $(seq $start_timestamp $end_timestamp); do
  key=$(printf "%016x" $timestamp | xxd -r -p)
  iv=$(printf "%032x" 0 | xxd -r -p) # Use a zero-filled 16-byte IV (you can change this value if needed)

  decrypted=$(echo -n "$ciphertext" | openssl enc -aes-128-cbc -d -K "$(echo -n "$key" | xxd -p)" -iv "$(echo -n "$iv" | xxd -p)" -nopad 2>/dev/null)

  # Assuming the decrypted message is a printable ASCII string, check if the decrypted bytes are in the ASCII range
  if [[ "$decrypted" =~ ^[[:print:]]*$ ]]; then
    found_key="$timestamp"
    decrypted_message="$decrypted"
    break
  fi
done

if [ -n "$found_key" ]; then
  echo "Key (Unix timestamp): $found_key"
  echo "Decrypted message: $decrypted_message"
else
  echo "No valid key found in the specified date range"
fi
