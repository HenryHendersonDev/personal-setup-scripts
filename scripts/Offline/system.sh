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

# Update and Upgrade the System
info_msg "_________UPDATE AND UPGRADE SYSTEM_________"
apt update || handle_error "Failed to update package lists"
apt upgrade -y || handle_error "Failed to upgrade packages"

# Install Gnome Extensions and Tweaks Packages
info_msg "_________INSTALL GNOME EXTENSIONS AND TWEAKS_________"
apt install -y gnome-shell-extension-manager || handle_error "Failed to install GNOME packages"

# Install xbindkeys
info_msg "_________INSTALL GNOME EXTENSIONS AND TWEAKS_________"
apt install xbindkeys xdotool -y|| handle_error "Failed to install XbindKey packages"

cat <<EOL > ~/.xbindkeysrc
"xdotool key ctrl+backslash"
    b:8

"xdotool key ctrl+shift+4"
    b:9
EOL

echo "~/.xbindkeysrc has been created or overwritten with the provided content."

xbindkeys

# Add sources
info_msg "_________ADD SOURCES TO APT_________"
apt update || warning_msg "Failed to update after adding sources"

# Install additional tools
log_info "Installing fzf and gnome-shell-extension-manager..."
apt install fzf gnome-shell-extension-manager || log_warning "Failed to install additional packages."

# Fix Network issues (if requested)
info_msg "_________NETWORK MANAGER SETUP_________"
if [ -f /etc/NetworkManager/NetworkManager.conf ]; then
    sed -i 's/^\(managed=\)false/\1true/' /etc/NetworkManager/NetworkManager.conf
    systemctl restart NetworkManager
    nmcli device status
fi

# Install Warp
info_msg "_________INSTALL WARP_________"
chmod 644 "./data/warp.deb"
dpkg -i "./data/warp.deb" || apt --fix-broken install -y

# Install VS Code
info_msg "_________INSTALL VS CODE_________"
chmod 644 "./data/vscode.deb"
dpkg -i "./data/vscode.deb" || apt --fix-broken install -y

# Install Chrome
info_msg "_________INSTALL CHROME_________"
chmod 644 "./data/chrome.deb"
dpkg -i "./data/chrome.deb" || apt --fix-broken install -y

# Install Mailhog
info_msg "_________INSTALL MAILHOG_________"
if [ -f "./data/MailHog" ]; then
    chmod +x "./data/MailHog"
    mv "./data/MailHog" /usr/local/bin/
fi

# Install fonts
info_msg "_________INSTALL FONT_________"
FONT_DIR="${ACTUAL_HOME}/.fonts"
mkdir -p "$FONT_DIR"
chown "${ACTUAL_USER}:${ACTUAL_USER}" "$FONT_DIR"

if [ -f "./data/fonts.zip" ]; then
    chmod 644 "./data/fonts.zip"
    sudo -u "$ACTUAL_USER" unzip -o "./data/fonts.zip" -d "./data/fonts"
    sudo -u "$ACTUAL_USER" mv "./data"/fonts/*.ttf "$FONT_DIR/" 2>/dev/null || warning_msg "No fonts to move"
    fc-cache -f
fi

# Download wallpaper to Downloads
info_msg "_________DOWNLOAD WALLPAPER_________"
sudo -u "$ACTUAL_USER" mv "./data/wallpaper.jpg" "${ACTUAL_HOME}/Downloads" || warning_msg "Failed to download wallpaper"
success_msg "Wallpaper downloaded to Downloads folder. You can set it manually if desired."

# Final system cleanup
info_msg "_________FINAL SYSTEM CLEANUP_________"
apt autoremove -y
apt clean
sudo dpkg --configure -a
sudo apt remove imagemagick -y

# Print final success message
MESSAGE="Setup completed! Please reboot your system to apply all changes."

echo -e "\033[1m$MESSAGE\033[0m"
for i in {10..1}; do
    echo "Rebooting in $i seconds..."
    sleep 1
done
echo "Rebooting now..."
sudo reboot
