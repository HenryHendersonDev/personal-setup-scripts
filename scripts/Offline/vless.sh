#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please run with 'sudo'."
    exit 1
fi

# Proceed with the rest of the script
echo "User has sudo privileges. Proceeding with the setup..."

# Step 1: Create the directory for Xray and download the package
echo "Creating directory for Xray..."
mkdir -p /usr/local/xray

echo "Downloading Xray..."
if [[ -f "./data/Xray-linux-64.zip" ]]; then
    mv "./data/Xray-linux-64.zip" "/usr/local/xray/Xray-linux-64.zip"
else
    echo "Xray package not found! Please ensure the file exists at ./data/Xray-linux-64.zip"
    exit 1
fi

# List directory contents to verify download
echo "Listing contents of /usr/local/xray..."
ls /usr/local/xray
# Step 2: Unzip Xray and clean up
echo "Unzipping Xray..."
if unzip /usr/local/xray/Xray-linux-64.zip -d /usr/local/xray; then
    echo "Xray unzipped successfully."
else
    echo "Failed to unzip Xray package!"
    exit 1
fi

# Remove the zip file after extraction
echo "Removing the zip file..."
rm /usr/local/xray/Xray-linux-64.zip

# Step 3: Create and edit Xray config.json
echo "Creating the Xray configuration file..."

# Step 4: Download Config creator Script.
if [[ -f "./data/vless-to-config.sh" ]]; then
    chmod 644 "./data/vless-to-config.sh"
    mv "./data/vless-to-config.sh" /usr/local/xray/
else
    echo "Config creator script not found! Please ensure the file exists at ./data/vless-to-config.sh"
    exit 1
fi

# Step 5 Download Proxy enable and disable scripts
mkdir -p /usr/local/xray/script

if [[ -f "./data/enable-xray-proxy.sh" && -f "./data/disable-xray-proxy.sh" ]]; then
    chmod 644 "./data/enable-xray-proxy.sh"
    chmod 644 "./data/disable-xray-proxy.sh"
    mv "./data/enable-xray-proxy.sh" /usr/local/xray/script
    mv "./data/disable-xray-proxy.sh" /usr/local/xray/script
else
    echo "Proxy enable/disable scripts not found! Please ensure the files exist at ./data/enable-xray-proxy.sh and ./data/disable-xray-proxy.sh"
    exit 1
fi

# Set necessary permissions for Xray scripts
chmod +x /usr/local/xray/script/*

# Ensure /etc/apt/apt.conf.d/95proxies file exists
touch /etc/apt/apt.conf.d/95proxies

# Set permissions more securely
chmod 755 /usr/local/xray
chmod +x /usr/local/xray/vless-to-config.sh

# Run the config creation script
echo "Running config creation script..."
/usr/local/xray/vless-to-config.sh

echo "Xray configuration file created successfully!"
