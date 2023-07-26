#!/bin/bash

# Enable and start firewall
echo "Enabling and starting firewall..."
systemctl enable firewalld
systemctl start firewalld
echo "Firewall enabled and started."

# Add firewall rules
echo "Adding firewall rules..."
firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload
echo "Firewall rules added."

# Disable unnecessary services
echo "Disabling unnecessary services..."
systemctl disable telnet.socket
systemctl disable vsftpd.service
echo "Unnecessary services disabled."

# Update packages
echo "Updating packages..."
yum update -y
echo "Packages updated."

# Enforce password complexity requirements
echo "Enforcing password complexity requirements..."
sed -i 's/password    requisite     pam_pwquality.so.*/password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type= minlen=12 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 difok=3/' /etc/pam.d/system-auth
echo "Password complexity requirements enforced."

# Install fail2ban
echo "Installing fail2ban..."
yum install epel-release -y
yum install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban
echo "Fail2ban installed and started."

# Set up log monitoring
echo "Setting up log monitoring..."
yum install logwatch -y
echo "Logwatch installed."

# Harden kernel parameters
echo "Hardening kernel parameters..."
echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
echo "kernel.exec-shield = 1" >> /etc/sysctl.conf
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
sysctl -p
echo "Kernel parameters hardened."

echo "Server hardening complete."