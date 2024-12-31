#!/bin/bash

# Check if the current shell is not zsh and switch to zsh if necessary
if [ -z "$ZSH_VERSION" ]; then
    echo "Switching to zsh to apply changes..."
    exec zsh "$0" "$@"
    exit
fi

# Remove system proxy settings
echo "Removing system proxy settings..."
gsettings set org.gnome.system.proxy mode "none"
unset http_proxy
unset https_proxy
unset ftp_proxy
unset all_proxy
echo "System proxy settings removed."

# Remove proxy variables from /etc/environment
echo "Removing proxy variables from /etc/environment..."
lines=$(cat /etc/environment)
if echo "$lines" | grep -q "http_proxy="; then
    sudo sed -i "/http_proxy=/d" /etc/environment
    sudo sed -i "/https_proxy=/d" /etc/environment
    sudo sed -i "/ftp_proxy=/d" /etc/environment
    sudo sed -i "/all_proxy=/d" /etc/environment
    echo "Proxy variables removed from /etc/environment."
else
    echo "No proxy variables found in /etc/environment."
fi

# Remove proxy settings from /etc/apt/apt.conf.d/95proxies (only if they exist)
echo "Removing proxy settings from /etc/apt/apt.conf.d/95proxies..."
if grep -q 'Acquire::http::Proxy "http://127.0.0.1:10808/";' /etc/apt/apt.conf.d/95proxies; then
    sudo sed -i '/Acquire::http::Proxy "http:\/\/127.0.0.1:10808\/";/d' /etc/apt/apt.conf.d/95proxies
    sudo sed -i '/Acquire::https::Proxy "http:\/\/127.0.0.1:10808\/";/d' /etc/apt/apt.conf.d/95proxies
    echo "Proxy settings removed from /etc/apt/apt.conf.d/95proxies."
else
    echo "No proxy settings found in /etc/apt/apt.conf.d/95proxies."
fi

# Remove proxy settings from ~/.zshrc and source it
echo "Removing proxy settings from ~/.zshrc..."
lines=$(cat ~/.zshrc)
if echo "$lines" | grep -q "# Set proxy setting"; then
    # Remove proxy settings and the line after it
    sed -i "/# Set proxy setting/,+3d" ~/.zshrc
    source ~/.zshrc
    echo "Proxy settings and separator line removed from ~/.zshrc."
else
    echo "No proxy settings found in ~/.zshrc."
fi
