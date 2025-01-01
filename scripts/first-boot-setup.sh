#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please run with 'sudo'."
    exit 1
fi

# Define color codes for logging
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}
log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}
log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}
log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root."
fi

# Prompt for username and add to sudo group
read -p "Enter the username to make admin: " username
if id "$username" &>/dev/null; then
    usermod -aG sudo "$username"
    log_success "User '$username' has been added to the sudo group and now has admin privileges."
else
    log_error "User '$username' does not exist. Please create the user first."
fi

# Update /etc/apt/sources.list
log_info "Updating APT sources..."
sed -i '1d' /etc/apt/sources.list
cat <<EOF >>/etc/apt/sources.list
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
EOF
log_success "APT sources updated."

# Configure Network Manager
log_info "Configuring Network Manager..."
sed -i '$d' /etc/network/interfaces
sed -i '$d' /etc/network/interfaces
sed -i '$d' /etc/network/interfaces
sed -i '$d' /etc/network/interfaces
sed -i '$d' /etc/NetworkManager/NetworkManager.conf
echo "managed=true" | tee -a /etc/network/interfaces >/dev/null

# Update and upgrade system packages
log_info "Updating and upgrading system packages..."
apt update && apt upgrade -y || log_warning "APT update/upgrade encountered issues."

# Remove unnecessary packages
log_info "Removing unnecessary packages..."
apt purge ifupdown -y || log_warning "Failed to purge 'ifupdown'."

# Install necessary packages
log_info "Installing necessary packages..."
apt install -y nala || log_error "Failed to install 'nala'."
nala update || log_warning "Failed to update package list with nala."
nala install -y gnome-core xorg network-manager-gnome wget sudo || log_error "Package installation failed."

# Fetch additional Debian packages
log_info "Fetching additional Debian packages..."
nala fetch --debian stable --limit 10 --auto || log_warning "Failed to fetch additional packages."

# Final success message
final_message="Setup completed! Please reboot your system to apply all changes."
log_success "$final_message"

# Countdown to reboot
for i in {10..1}; do
    echo -e "Rebooting in $i seconds..."
    sleep 1
done

log_info "Rebooting now..."
reboot
