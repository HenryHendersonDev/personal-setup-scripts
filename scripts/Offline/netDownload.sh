#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

success_msg() {
    echo -e "${GREEN}$1${NC}"
}

info_msg() {
    echo -e "${BLUE}$1${NC}"
}

warning_msg() {
    echo -e "${YELLOW}$1${NC}"
}

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    handle_error "This script must be run as root. Please run with 'sudo'."
fi

# Get the actual user who invoked sudo
ACTUAL_USER=$(logname || who am i | awk '{print $1}')
ACTUAL_HOME=$(eval echo ~${ACTUAL_USER})

# Install utilities
info_msg "_________INSTALL UTILITIES_________"
apt update || handle_error "Failed to update package lists"
apt install -y postgresql postgresql-contrib flatpak gnome-software-plugin-flatpak neofetch imwheel || warning_msg "Failed to install some utilities"
systemctl start postgresql || warning_msg "PostgreSQL service failed to start"
systemctl enable postgresql
systemctl enable preload

# Install Brave Browser
info_msg "_________INSTALL BRAVE BROWSER_________"
sudo apt install curl

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install brave-browser

# Install Redis
info_msg "_________INSTALL REDIS_________"
apt install -y redis-server || warning_msg "Failed to install Redis"
systemctl start redis-server || warning_msg "Redis service failed to start"
systemctl enable redis-server

# Fix Scroll Issue
cat >"${ACTUAL_HOME}/.imwheelrc" <<EOF
".*"
None,      Up,   Button4, 1
None,      Down, Button5, 1
EOF

imwheel
echo 'imwheel' >>"${ACTUAL_HOME}/.xinitrc"

# Verify services
info_msg "_________SERVICE STATUS CHECK_________"
systemctl status postgresql --no-pager || warning_msg "PostgreSQL service check failed"
systemctl status redis-server --no-pager || warning_msg "Redis service check failed"

# Final system cleanup
info_msg "_________FINAL SYSTEM CLEANUP_________"
apt autoremove -y
apt clean
sudo dpkg --configure -a
sudo apt remove imagemagick -y
