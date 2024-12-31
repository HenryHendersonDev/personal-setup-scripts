#!/bin/bash

# Check if the current shell is not zsh and switch to zsh if necessary
if [ -z "$ZSH_VERSION" ]; then
    echo "Switching to zsh to apply changes..."
    exec zsh "$0" "$@"
    exit
fi

# Set system proxy using gsettings
echo "Setting system proxy using gsettings..."
gsettings set org.gnome.system.proxy mode "manual"
gsettings set org.gnome.system.proxy.socks host "127.0.0.1"
gsettings set org.gnome.system.proxy.socks port 10808
echo "System proxy set using gsettings."

# Set proxy environment variables for the current session
echo "Setting proxy environment variables for the current session..."
export http_proxy="socks5://127.0.0.1:10808"
export https_proxy="socks5://127.0.0.1:10808"
export ftp_proxy="socks5://127.0.0.1:10808"
export all_proxy="socks5://127.0.0.1:10808"
echo "Proxy environment variables set for the current session."

# Insert proxy settings at the top of /etc/environment (only if they don't already exist)
echo "Inserting proxy settings at the top of /etc/environment..."
if ! grep -q 'http_proxy="socks5://127.0.0.1:10808"' /etc/environment; then
    echo -e "http_proxy=\"socks5://127.0.0.1:10808\"
https_proxy=\"socks5://127.0.0.1:10808\"
ftp_proxy=\"socks5://127.0.0.1:10808\"
all_proxy=\"socks5://127.0.0.1:10808\"
$(cat /etc/environment)" | sudo tee /etc/environment >/dev/null
    echo "Proxy settings inserted at the top of /etc/environment."
else
    echo "Proxy settings already exist in /etc/environment. Skipping insertion."
fi

# Append the proxy settings to ~/.zshrc, preserving the existing content (only if they don't already exist)
echo "Appending proxy settings to ~/.zshrc..."
if ! grep -q '# Set proxy setting' ~/.zshrc; then
    echo -e "# Set proxy setting
export http_proxy=\"http://127.0.0.1:10809\"
export https_proxy=\"http://127.0.0.1:10809\"
export all_proxy=\"socks5://127.0.0.1:10808\"
$(cat ~/.zshrc)" >~/.zshrc
    echo "Proxy settings appended to ~/.zshrc."
else
    echo "Proxy settings already exist in ~/.zshrc. Skipping appending."
fi

# Source the updated ~/.zshrc
echo "Sourcing the updated ~/.zshrc..."
source ~/.zshrc
echo "Proxy settings applied and ~/.zshrc reloaded."
