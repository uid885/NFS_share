#!/bin/bash
# Author:           Christo Deale                  
# Date  :           2024-01-23           
# NFS_share_setup:  Utility to setup NFS server with open anon access

# Check if NFS server is installed, if not, install it
if ! rpm -q nfs-utils > /dev/null 2>&1; then
    sudo dnf install -y nfs-utils
fi

# Input for directory name and location
read -p "Enter directory name: " dir_name
dir_location="/home/username/$dir_name"

# Create the directory if it doesn't exist
if [ ! -d "$dir_location" ]; then
    sudo mkdir -p "$dir_location"
fi

# Add NFS export configuration to /etc/exports
echo "$dir_location *(rw,all_squash,anonuid=65534,anongid=65534)" | sudo tee -a /etc/exports > /dev/null

# Export the NFS share
sudo exportfs -rv

# Start and enable NFS server
sudo systemctl start nfs-server
sudo systemctl enable nfs-server

# Check if NFS server and rpcbind are active
if sudo systemctl is-active nfs-server && sudo systemctl is-active rpcbind; then
    # Change owner of the NFS share to nobody:nobody
    sudo chown -R nobody:nobody "$dir_location"

    # Disable firewalld (since you mentioned it's an air-gapped system)
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld

    # Restart NFS server for the changes to take effect
    sudo systemctl restart nfs-server
    echo "NFS share is set up with nobody:nobody as the owner."
else
    echo "NFS server or rpcbind is not active. Please check the status."
fi
