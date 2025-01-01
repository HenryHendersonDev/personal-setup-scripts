#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Error handling function
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Success message function
success_msg() {
    echo -e "${GREEN}$1${NC}"
}

# Info message function
info_msg() {
    echo -e "${BLUE}$1${NC}"
}

# Warning message function
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

# Backup important files
backup_dir="${ACTUAL_HOME}/setup_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir" || handle_error "Failed to create backup directory"

# Function to check command success
check_command() {
    if ! "$@"; then
        handle_error "Command failed: $*"
    fi
}

# Update and Upgrade the System
info_msg "_________UPDATE AND UPGRADE SYSTEM_________"
check_command apt update
check_command apt upgrade -y

# Install Flatpak and dependencies
info_msg "_________INSTALL FLATPAK AND DEPENDENCIES_________"
check_command apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Gnome Extensions and Tweaks Packages
info_msg "_________INSTALL GNOME EXTENSIONS AND TWEAKS_________"
check_command apt install gnome-shell-extensions gnome-tweaks gnome-shell-extension-manager -y

# Define extension links
LINKS=(
    "https://extensions.gnome.org/extension/3843/just-perfection/"
    "https://extensions.gnome.org/extension/3210/compiz-windows-effect/"
    "https://extensions.gnome.org/extension/3193/blur-my-shell/"
    "https://extensions.gnome.org/extension/307/dash-to-dock/"
    "https://extensions.gnome.org/extension/1460/vitals/"
    "https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/"
    "https://extensions.gnome.org/extension/779/clipboard-indicator/"
)

# Log the links array for user to install
warning_msg "_________INSTALL GNOME EXTENSIONS FROM LINKS_________"
for link in "${LINKS[@]}"; do
    echo -e "${BLUE}$link${NC}"
done

echo -e "${YELLOW}Press Enter to continue once you have installed the extensions.${NC}"
echo -e "${YELLOW}Alternatively, press 'o' to open all the extension links in your browser after installation.${NC}"

read -n 1 -s -r -p "Press 'o' to open the links or press Enter to continue..."

if [[ $REPLY == 'o' ]]; then
    success_msg "Opening links in your browser..."
    for link in "${LINKS[@]}"; do
        sudo -u "$ACTUAL_USER" xdg-open "$link" || warning_msg "Failed to open: $link"
        sleep 1
    done
    warning_msg "Please ensure you've installed the extensions. Press Enter to continue."
    read -p "Press Enter to continue once you have installed the extensions..."
fi

# Create temp directory in Downloads
info_msg "_________CREATE TEMP DIRECTORY_________"
TEMP_DIR="${ACTUAL_HOME}/Downloads/temp"
mkdir -p "$TEMP_DIR" || handle_error "Failed to create temp directory"
chown -R "${ACTUAL_USER}:${ACTUAL_USER}" "$TEMP_DIR"

# Download backup files with error checking
info_msg "_________DOWNLOAD BACKUP FILES_________"
wget -P "$TEMP_DIR" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/backups/gnome-backup.txt || handle_error "Failed to download gnome-backup.txt"
wget -P "$TEMP_DIR" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/backups/gnome-extensions-backup.txt || handle_error "Failed to download gnome-extensions-backup.txt"

# Restore settings from backups
info_msg "_________RESTORE SETTINGS FROM BACKUPS_________"
if [ -f "$TEMP_DIR/gnome-backup.txt" ]; then
    dconf load /org/gnome/ <"$TEMP_DIR/gnome-backup.txt"
fi
if [ -f "$TEMP_DIR/gnome-extensions-backup.txt" ]; then
    dconf load /org/gnome/shell/extensions/ <"$TEMP_DIR/gnome-extensions-backup.txt"
fi

# List GNOME extensions
info_msg "_________LIST GNOME EXTENSIONS_________"
gnome-extensions list

# Add sources
info_msg "_________ADD SOURCES TO APT_________"
echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" | tee -a /etc/apt/sources.list
check_command apt update -y

# Fix Network issues (if requested)
info_msg "_________NETWORK MANAGER SETUP_________"
if [ -f /etc/NetworkManager/NetworkManager.conf ]; then
    sed -i 's/^\(managed=\)false/\1true/' /etc/NetworkManager/NetworkManager.conf
    systemctl restart NetworkManager
    nmcli device status
fi

# Remove and reinstall packages
info_msg "_________PACKAGE MANAGEMENT_________"
apt remove --purge gnome-calculator gnome-characters gnome-contacts gnome-software totem gnome-system-monitor firefox-esr -y || warning_msg "Some packages couldn't be removed"
check_command apt install nautilus gnome-calculator gnome-system-monitor -y

# Install utilities
info_msg "_________INSTALL UTILITIES_________"
check_command apt install wget curl neofetch postgresql postgresql-contrib git -y
systemctl start postgresql || warning_msg "PostgreSQL service failed to start"
systemctl enable postgresql

# Install Warp
info_msg "_________INSTALL WARP_________"
wget https://app.warp.dev/download?package=deb -O "${TEMP_DIR}/warp.deb" || handle_error "Failed to download Warp"
dpkg -i "${TEMP_DIR}/warp.deb" || apt --fix-broken install -y

# Install Apps using Flatpak
info_msg "_________INSTALL FLATPAK APPS_________"
flatpak install flathub com.redis.RedisInsight -y

# Install Brave Browser
info_msg "_________INSTALL BRAVE BROWSER_________"
if ! [ -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ]; then
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
    check_command apt update -y
fi
check_command apt install brave-browser -y

# Install Redis
info_msg "_________INSTALL REDIS_________"
check_command apt install redis-server -y
systemctl start redis-server || warning_msg "Redis service failed to start"
systemctl enable redis-server

# Install Mailhog
info_msg "_________INSTALL MAILHOG_________"
wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64 -O "${TEMP_DIR}/MailHog" || handle_error "Failed to download MailHog"
chmod +x "${TEMP_DIR}/MailHog"
mv "${TEMP_DIR}/MailHog" /usr/local/bin/

# Install fonts
info_msg "_________INSTALL FONT_________"
FONT_DIR="${ACTUAL_HOME}/.fonts"
mkdir -p "$FONT_DIR"
wget -P "$TEMP_DIR" https://github.com/HenryHendersonDev/personal-setup-scripts/raw/main/assets/fonts.zip || handle_error "Failed to download fonts"
unzip -o "$TEMP_DIR/fonts.zip" -d "$TEMP_DIR/fonts"
mv "$TEMP_DIR"/fonts/*.ttf "$FONT_DIR/"
chown -R "${ACTUAL_USER}:${ACTUAL_USER}" "$FONT_DIR"
fc-cache -f

# Setup wallpaper
info_msg "_________SETUP WALLPAPER_________"
WALLPAPER_URL="https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/assets/wallpaper.jpg"
wget -P "$TEMP_DIR" "$WALLPAPER_URL" || handle_error "Failed to download wallpaper"
WALLPAPER_PATH="$TEMP_DIR/wallpaper.jpg"
sudo -u "$ACTUAL_USER" gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
sudo -u "$ACTUAL_USER" gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"

# Clean up the temp directory
info_msg "_________CLEAN UP_________"
rm -rf "$TEMP_DIR"

# Final system cleanup
info_msg "_________FINAL SYSTEM CLEANUP_________"
apt autoremove -y
apt clean -y

success_msg "Script executed successfully. All tasks are complete."

# Verify services
info_msg "_________SERVICE STATUS CHECK_________"
systemctl status postgresql --no-pager || warning_msg "PostgreSQL service check failed"
systemctl status redis-server --no-pager || warning_msg "Redis service check failed"

# Print final success message
success_msg "Setup completed! Please reboot your system to apply all changes."
