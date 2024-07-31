#!/bin/bash

# URLs of the files to download
url1="https://raw.githubusercontent.com/rahul-masal/testing/main/modify_hosts_and_resolv.sh"
url2="https://raw.githubusercontent.com/rahul-masal/testing/main/logo1.png"

# Download the files
wget -O file1 "$url1"
wget -O file2 "$url2"

echo "Files downloaded successfully."
