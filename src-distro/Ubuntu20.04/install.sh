#!/bin/sh

echo "poor implementation - exiting"
exit 0

# SYSTEM UPDATES
#
# Keeping the system updated is vital before starting anything on your system.
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# Enable automatic updates
sudo apt-get install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades


# USERS
#
# Disable root account
sudo passwd -l root
# To enable root account type
# sudo passwd -u root


# Turn on firewall
sudo apt-get install -y ufw
# Turn it on
#sudo ufw enable
sudo systemctl start ufw
# Enable it on reboot
sudo systemctl enable ufw
# Enable logging
sudo ufw logging on
# Setup rules
sudo ufw default deny incoming
sudo ufw default allow outgoing
# Allow ssh service to configure ports
sudo ufw allow ssh
# Block brute force attacks on ssh service
#
# Rate limiting is another useful feature of firewalls that can block connections that are obviously abusive.
# This is used to protect against an attacker attempting to bruteforce an open SSH port.
# Obviously you could whitelist the port to protect it entirely, but rate limiting is useful anyway.
# By default, UFW rate limits 6 connections per 30 seconds, and it’s intended to be used for SSH.
sudo ufw limit ssh
#
# Restart it just to be safe
sudo systemctl restart ufw

# EDIT /etc/sysctl.conf
#
# This will:
# - Limit network-transmitted configuration for IPv4
# - Limit network-transmitted configuration for IPv6
# - Turn on execshield protection
# - Prevent against the common 'syn flood attack'
# - Turn on source IP address verification
# - Prevents a cracker from using a spoofing attack against the IP address of the server.
# - Logs several types of suspicious packets, such as spoofed packets, source-routed packets, and redirects.

# Copy settings file
unixtimestamp=`date +%s`
sudo cp /etc/sysctl.conf /etc/sysctl.conf${unixtimestamp}
sudo cp sysctl.conf /etc/sysctl.conf
# Apply new settings
sudo sysctl -p


# Secure SSH
sudo cp /etc/sshd_config /etc/sshd_config${unixtimestamp}
sudo cp sshd_config /etc/sshd_config
sudo service ssh restart


# Lock shared memory
# TODO:
#
#sudo nano /etc/fstab
#: tmpfs	/run/shm	tmpfs	ro,noexec,nosuid	0 0


