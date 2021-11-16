# hardened-linux
This document is based on ubuntu server 20.04 LTD.

Note: 
- Specific config files are located in src-distro.
- An early atempt has been made at automating this. But it has been abandoned for now. 

## Keep system updated

    # Fresh update
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y

    # Enable automatic updates
    sudo apt-get install unattended-upgrades -y
    sudo dpkg-reconfigure -plow unattended-upgrades


## Firewall
Incomming traffic is blocked by default.

    sudo apt-get install -y ufw
    # Turn it on
    sudo ufw enable

    # Enable logging
    sudo ufw logging on

## Network /etc/sysctl.conf
Network is important to protect. The will edit the /etc/sysctl.conf file to:
- Limit network-transmitted configuration for IPv4
- Limit network-transmitted configuration for IPv6
- Turn on execshield protection
- Prevent against the common 'syn flood attack'
- Turn on source IP address verification
- Prevents a cracker from using a spoofing attack against the IP address of the server.
- Logs several types of suspicious packets, such as spoofed packets, source-routed packets, and redirects.

Copy new settings file:

    # Backup old settings file
    sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
    
    # Copy in new file
    sudo cp src-distro/Ubuntu20.04/sysctl.conf /etc/sysctl.conf
    
    # Apply new settings
    sudo sysctl -p

## SSH server (sshd)
The basic rules of hardening SSH are:
- No password for SSH access (use private key)
- Don't allow root to SSH (the appropriate users should SSH in, then `su` or `sudo`)
- Use `sudo` for users so commands are logged
- Log unauthorised login attempts (and consider software to block/ban users who try to access your server too many times, like fail2ban)
- Lock down SSH to only the ip range your require (if you feel like it)

### First install ssh on server

    sudo apt-get install ssh -y
    
    # Generate keys for user on server you will login to:
    ssh-keygen

### Setup keys on client
Assure you have installed ssh on server and that the sshd service is running there.

On client, test ssh connection to server with server username and password:

    ssh username@server
    exit


On client, generate key-pair:

    ssh-keygen

On client copy pub-key to server:

    ssh-copy-id [user]@[server]


### Harden ssh server
    # On server, backup sshd_config (I newer figuered out which config file ruled)
    sudo cp /etc/sshd_config /etc/sshd_config.backup
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

In both /etc/ssh/sshd_config and /etc/sshd_config change the following:
    
    # Logging
    SyslogFacility AUTH
    LogLevel VERBOSE

    # Authentication:

    LoginGraceTime 2m
    PermitRootLogin no
    StrictModes yes
    MaxAuthTries 6
    MaxSessions 10

    # To disable tunneled clear text passwords, change to no here!
    PasswordAuthentication no
    PermitEmptyPasswords no

    # Change to no to disable s/key passwords
    ChallengeResponseAuthentication yes

Now restart sshd server

    # Restart service 
    sudo systemctl restart sshd

### Open firewall on ssh server
    # Allow ssh service to configure ports
    sudo ufw allow ssh

### Block brute force attacks on ssh server
Rate limiting is another useful feature of firewalls that can block connections that are obviously abusive.
This is used to protect against an attacker attempting to bruteforce an open SSH port. Obviously you could whitelist the port to protect it entirely, but rate limiting is useful anyway. By default, UFW rate limits 6 connections per 30 seconds, and it’s intended to be used for SSH.

    sudo ufw limit ssh

### Test client to server connection
On client test that password login fails:

    ssh [user]@[server] -o PubkeyAuthentication=no

Test that key login works:

    ssh [user]@[server]