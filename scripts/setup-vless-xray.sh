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
sudo mkdir -p /usr/local/xray

echo "Downloading Xray..."
sudo curl -L https://github.com/XTLS/Xray-core/releases/download/v24.12.18/Xray-linux-64.zip -o /usr/local/xray/Xray-linux-64.zip

# List directory contents to verify download
echo "Listing contents of /usr/local/xray..."
ls /usr/local/xray

# Step 2: Unzip Xray and clean up
echo "Unzipping Xray..."
sudo unzip /usr/local/xray/Xray-linux-64.zip -d /usr/local/xray

# Remove the zip file after extraction
echo "Removing the zip file..."
sudo rm /usr/local/xray/Xray-linux-64.zip

# Step 3: Create and edit Xray config.json
echo "Creating the Xray configuration file..."

sudo bash -c 'cat <<EOF > /usr/local/xray/config.json
{
  "log": {
    "loglevel": "info"
  },
  "inbounds": [
    {
      "tag": "socks-in",
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "udp": true,
        "auth": "noauth"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "tag": "http-in",
      "port": 10809,
      "protocol": "http",
      "settings": {},
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "christmas.arunod.store",
            "port": 443,
            "users": [
              {
                "id": "c4b87bb5-88ff-494b-a1e8-571aa74b63c1",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "serverName": "aka.ms",
          "allowInsecure": true,
          "fingerprint": "chrome",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        },
        "wsSettings": {
          "path": "/"
        }
      }
    }
  ]
}
EOF'

# Step 5 Download Proxy enable and disable scripts
sudo mkdir -p /usr/local/xray/script
wget -P /usr/local/xray/script https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/scripts/proxy/enable-xray-proxy.sh
wget -P /usr/local/xray/script https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/scripts/proxy/disable-xray-proxy.sh
sudo touch /etc/apt/apt.conf.d/95proxies
