#!/bin/bash

# Switch to root user
expect <<EOD
spawn sudo su
expect "Password:"
send "gogreen@g1\r"
expect eof
EOD

# Continue as root user
sudo su - <<EOF

# Edit the sudoers file
echo "Editing the sudoers file..."
echo "admin ALL=(ALL) NOPASSWD: /usr/sbin/openvpn" >> /etc/sudoers
echo "admin ALL=(ALL) NOPASSWD: /usr/sbin/ifconfig" >> /etc/sudoers

# Update package list and install required packages
echo "Updating package list and installing required packages..."
apt update
apt install -y python3-pip expect
apt install freerdp2-x11
apt install python3-tk

# Install subprocess.run module
pip3 install subprocess.run --break-system-packages
pip3 install pyinstaller --break-system-packages

#Combine file
wget https://raw.githubusercontent.com/rahul-masal/testing/main/combine.ovpn -O /home/admin/vpn/

# Create the VPN folder and Python script
echo "Creating the VPN folder and Python script..."
mkdir -p /home/admin/vpn
cat <<'EOT' > /home/admin/vpn/vpn.py
import subprocess
import time

# Path to your OpenVPN configuration file and secret file
CONFIG_FILE = "/home/admin/vpn/combine.ovpn"
#SECRET_FILE = "/home/admin/vpn/secret"

# Your private key password
PRIVATE_KEY_PASSWORD = "vpn@123#"

def is_vpn_connected():
    check_command = ["sudo", "ifconfig", "tun0"]
    check_result = subprocess.run(check_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return b"tun0" in check_result.stdout

def is_internet_available():
    try:
        # Ping a reliable server (Google's DNS server)
        ping_command = ["ping", "-c", "1", "8.8.8.8"]
        ping_result = subprocess.run(ping_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return ping_result.returncode == 0
    except Exception as e:
        print(f"Error checking internet connection: {e}")
        return False

def connect_vpn():
    expect_script = f"""
    spawn sudo openvpn --config "{CONFIG_FILE}" --dev tun0
    expect "Enter Private Key Password:"
    send "{PRIVATE_KEY_PASSWORD}\\r"
    expect eof
    """
    command = ["expect", "-c", expect_script]
    subprocess.run(command)

while True:
    if is_vpn_connected():
        print("VPN is connected.")
        if is_internet_available():
            print("Internet is available. Sleeping for 30 seconds.")
            time.sleep(30)
        else:
            print("Internet is down. Attempting to reconnect VPN.")
            connect_vpn()
            time.sleep(10)  # Give some time for the VPN to reconnect
    else:
        print("VPN is not connected. Attempting to connect.")
        connect_vpn()
        time.sleep(10)  # Give some time for the VPN to connect

    # Sleep for a short period before re-checking the VPN connection
    time.sleep(10)
EOT

# Add the VPN script to crontab
echo "Adding the VPN script to crontab..."
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/python3 /home/admin/vpn/vpn.py") | crontab -

EOF

# Delete this script after execution
rm -- "$0"

echo "VPN setup script completed."
