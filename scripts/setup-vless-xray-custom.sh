#!/bin/bash

echo "What is Xray Installation Location ?:"
read vless_url

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Please run with 'sudo'."
  exit 1
fi

# Proceed with the rest of the script
echo "User has sudo privileges. Proceeding with the setup..."

# Step 1: Create the directory for Xray and download the package
echo "Creating directory for Xray..."
sudo mkdir -p $vless_url

echo "Downloading Xray..."
sudo curl -L https://github.com/XTLS/Xray-core/releases/download/v24.12.18/Xray-linux-64.zip -o $vless_url/Xray-linux-64.zip

# List directory contents to verify download
echo "Listing contents of $vless_url..."
ls $vless_url

# Step 2: Unzip Xray and clean up
echo "Unzipping Xray..."
sudo unzip $vless_url/Xray-linux-64.zip -d $vless_url

# Remove the zip file after extraction
echo "Removing the zip file..."
sudo rm $vless_url/Xray-linux-64.zip

# Step 3: Create and edit Xray config.json
echo "Creating the Xray configuration file..."

# Step 4: Download Config creator Script.
sudo curl -L https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/scripts/subScript/vless-to-config.sh -o $vless_url/vless-to-config.sh

# Step 5 Download Proxy enable and disable scripts
sudo mkdir -p $vless_url/script
wget -P $vless_url/script https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/scripts/proxy/enable-xray-proxy.sh
wget -P $vless_url/script https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/scripts/proxy/disable-xray-proxy.sh
sudo touch /etc/apt/apt.conf.d/95proxies
sudo chmod +x $vless_url/script/*

sudo $vless_url/vless-to-config.sh

echo "Xray configuration file created successfully!"
