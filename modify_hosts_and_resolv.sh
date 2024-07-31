#!/bin/bash

# Check if the root password is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <root_password>"
  exit 1
fi

# Define the root password from the command-line argument
ROOT_PASSWORD="$1"

# Function to execute subsequent commands as root using sudo
execute_as_root() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - Switching to root user to perform the operations..."
  echo "$ROOT_PASSWORD" | su -c "sudo -S bash -c '$1'"
  if [ $? -ne 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Error executing: $1"
    echo "Error: Check the console output above for details."
    exit 1
  else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Successfully executed: $1"
  fi
}

# Remount the root filesystem as read-write
execute_as_root 'mount -o remount,rw /'

# Edit /etc/hosts file
# Create a backup of the current /etc/hosts file
execute_as_root 'cp /etc/hosts /etc/hosts.bak'
echo "$(date +'%Y-%m-%d %H:%M:%S') - Backup of /etc/hosts created at /etc/hosts.bak."

# Append new entries to /etc/hosts
execute_as_root 'bash -c "echo -e \"216.239.38.120  www.google.com\\n216.239.38.120  www.youtube.com\\n\" >> /etc/hosts"'
echo "$(date +'%Y-%m-%d %H:%M:%S') - Entries appended to /etc/hosts."

# Print completion message
echo "$(date +'%Y-%m-%d %H:%M:%S') - Modifications to /etc/hosts have been completed."
echo "Modifications completed successfully."
