#!/bin/bash

# Define variables
public_ip=<public_ip_address>
subnet_mask=<subnet_mask>
default_gateway=<default_gateway>
primary_dns=<primary_dns_server>
secondary_dns=<secondary_dns_server>
private_ip=<private_ip_address>
private_subnet_mask=<private_subnet_mask>

# Configure public IP address
echo "Configuring public IP address..."
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
BOOTPROTO=none
IPADDR=$public_ip
NETMASK=$subnet_mask
GATEWAY=$default_gateway
DNS1=$primary_dns
DNS2=$secondary_dns
EOF

systemctl restart network

echo "Public IP address configured."

# Configure private IP address
echo "Configuring private IP address..."
cat > /etc/sysconfig/network-scripts/ifcfg-eth0:0 << EOF
BOOTPROTO=none
IPADDR=$private_ip
NETMASK=$private_subnet_mask
EOF

ip addr add $private_ip/$private_subnet_mask dev eth0:0

echo "Private IP address configured."

DcmfE6Xt5KmUlDfV