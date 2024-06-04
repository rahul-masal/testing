#!/usr/bin/env bash

ROOT_PASSWORD="thinux"  # replace with the actual root password

# Expect script to run commands as root
run_as_root() {
    /usr/bin/expect <<EOF
set timeout -1
spawn su -
expect "Password:"
send "$ROOT_PASSWORD\r"
expect "# "
send "$1\r"
expect "# "
send "exit\r"
expect eof
EOF
}

# Setup function
setup() {
    run_as_root "mount -o remount,rw /"
    run_as_root "mkdir -p /root/agent"
    
    AGENT_SCRIPT="#!/bin/bash

# Name of the Elastic Agent service
SERVICE_NAME=\"elastic-agent\"

# Check if the service is active
if ! systemctl is-active --quiet \$SERVICE_NAME; then
    # Service is inactive, attempt to start it
    systemctl start \$SERVICE_NAME
    if systemctl is-active --quiet \$SERVICE_NAME; then
        echo \"\$(date) - \$SERVICE_NAME was inactive and has been started successfully.\" >> /var/log/elastic_agent_check.log
    else
        echo \"\$(date) - Failed to start \$SERVICE_NAME.\" >> /var/log/elastic_agent_check.log
    fi
else
    # Service is active
    echo \"\$(date) - \$SERVICE_NAME is already active.\" >> /var/log/elastic_agent_check.log
fi"

    run_as_root "echo \"$AGENT_SCRIPT\" > /root/agent/agent.sh"
    run_as_root "chmod +x /root/agent/agent.sh"
    run_as_root "cp /root/agent/agent.sh /usr/local/bin/agent.sh"
    run_as_root "echo '* * * * * /usr/local/bin/agent.sh' | crontab -u root -"
    run_as_root "sed -i '/^exit 0/i /etc/init.d/cron start' /etc/rc.local"
    run_as_root "systemctl enable cron"
    run_as_root "systemctl start cron"
    echo "Setup completed."
}

# Uninstall function
uninstall() {
    run_as_root "rm -f /usr/local/bin/agent.sh"
    run_as_root "crontab -u root -r"
    run_as_root "sed -i '/\/etc\/init.d\/cron start/d' /etc/rc.local"
    run_as_root "systemctl disable cron"
    run_as_root "systemctl stop cron"
    run_as_root "rm -rf /root/agent"
    echo "Uninstallation completed."
}

# Check function
check() {
    run_as_root "systemctl is-active elastic-agent && echo 'Elastic Agent is running' || echo 'Elastic Agent is not running'"
    crontab -u root -l | grep -q "/usr/local/bin/agent.sh" && echo "Cron job is set" || echo "Cron job is not set"
    grep -q "/etc/init.d/cron start" /etc/rc.local && echo "rc.local is set" || echo "rc.local is not set"
    echo "Check completed."
}

# Menu function
menu() {
    PS3='Please enter your choice: '
    options=("Setup" "Uninstall" "Check" "Exit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Setup")
                setup
                ;;
            "Uninstall")
                uninstall
                ;;
            "Check")
                check
                ;;
            "Exit")
                break
                ;;
            *) echo "Invalid option $REPLY";;
        esac
    done
}

# Run the menu
menu
