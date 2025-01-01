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

# Create temp directory in Downloads first
info_msg "_________CREATE TEMP DIRECTORY_________"
TEMP_DIR="${ACTUAL_HOME}/Downloads/temp"
mkdir -p "$TEMP_DIR" || handle_error "Failed to create temp directory"
chown -R "${ACTUAL_USER}:${ACTUAL_USER}" "$TEMP_DIR"

# Create scripts directory
SCRIPTS_DIR="${ACTUAL_HOME}/Downloads/scripts"
mkdir -p "$SCRIPTS_DIR" || handle_error "Failed to create scripts directory"
chown -R "${ACTUAL_USER}:${ACTUAL_USER}" "$SCRIPTS_DIR"

# Backup important files
backup_dir="${ACTUAL_HOME}/setup_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir" || handle_error "Failed to create backup directory"

# Function to check command success
check_command() {
    if ! "$@"; then
        echo -e "${RED}Command failed: $*${NC}"
        handle_error "Command execution failed"
    fi
}

# Function to run command with error logging
run_with_error_check() {
    if ! "$@"; then
        echo -e "${RED}Failed to execute: $*${NC}"
        return 1
    fi
    return 0
}

# Update and Upgrade the System
info_msg "_________UPDATE AND UPGRADE SYSTEM_________"
check_command apt update
check_command apt install nala -y
check_command nala update
check_command nala upgrade -y

# Install Flatpak and dependencies
info_msg "_________INSTALL FLATPAK AND DEPENDENCIES_________"
check_command nala install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Gnome Extensions and Tweaks Packages
info_msg "_________INSTALL GNOME EXTENSIONS AND TWEAKS_________"
check_command nala install gnome-shell-extensions gnome-tweaks gnome-shell-extension-manager -y

# Download and install extensions
info_msg "_________DOWNLOADING AND INSTALLING GNOME EXTENSIONS_________"
wget -P "$TEMP_DIR" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/assets/extension.zip || handle_error "Failed to download extensions"
mkdir -p "$TEMP_DIR/extensions"
unzip -o "$TEMP_DIR/extension.zip" -d "$TEMP_DIR/extensions" || handle_error "Failed to unzip extensions"
chmod -R 755 "$TEMP_DIR/extensions"

# Install and enable extensions
cd "$TEMP_DIR/extensions" || handle_error "Failed to access extensions directory"
for ext in *.shell-extension.zip; do
    gnome-extensions install --force "./$ext" || warning_msg "Failed to install extension: $ext"
done

# Enable extensions
gnome-extensions enable just-perfection-desktop@just-perfection
gnome-extensions enable compiz-windows-effect@hermes83.github.com
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable Vitals@CoreCoding.com
gnome-extensions enable compiz-alike-magic-lamp-effect@hermes83.github.com
gnome-extensions enable clipboard-indicator@tudmotu.com

# Download backup files with error checking
info_msg "_________DOWNLOAD BACKUP FILES_________"
wget -P "$TEMP_DIR" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/backups/gnome-backup.txt || handle_error "Failed to download gnome-backup.txt"
wget -P "$TEMP_DIR" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/backups/gnome-extensions-backup.txt || handle_error "Failed to download gnome-extensions-backup.txt"

# Restore settings from backups
info_msg "_________RESTORE SETTINGS FROM BACKUPS_________"
# Create dconf directories if they don't exist
dconf write /org/gnome/dummy "" 2>/dev/null || dconf reset -f /org/gnome/
dconf write /org/gnome/shell/extensions/dummy "" 2>/dev/null || dconf reset -f /org/gnome/shell/extensions/

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
check_command nala update -y

# Fix Network issues (if requested)
info_msg "_________NETWORK MANAGER SETUP_________"
if [ -f /etc/NetworkManager/NetworkManager.conf ]; then
    sed -i 's/^\(managed=\)false/\1true/' /etc/NetworkManager/NetworkManager.conf
    systemctl restart NetworkManager
    nmcli device status
fi

# Remove and reinstall packages
info_msg "_________PACKAGE MANAGEMENT_________"
nala remove --purge gnome-calculator gnome-characters gnome-contacts gnome-software totem gnome-system-monitor firefox-esr -y || warning_msg "Some packages couldn't be removed"
check_command nala install nautilus gnome-calculator gnome-system-monitor -y

# Install utilities
info_msg "_________INSTALL UTILITIES_________"
check_command nala install wget curl neofetch postgresql postgresql-contrib git -y
systemctl start postgresql || warning_msg "PostgreSQL service failed to start"
systemctl enable postgresql

# Install Warp
info_msg "_________INSTALL WARP_________"
wget https://app.warp.dev/download?package=deb -O "${TEMP_DIR}/warp.deb" || handle_error "Failed to download Warp"
dpkg -i "${TEMP_DIR}/warp.deb" || nala --fix-broken install -y

# Install Apps using Flatpak
info_msg "_________INSTALL FLATPAK APPS_________"
if ! flatpak install flathub com.redis.RedisInsight -y; then
    echo -e "${RED}Failed to install RedisInsight${NC}"
fi

if ! flatpak install flathub md.obsidian.Obsidian -y; then
    echo -e "${RED}Failed to install Obsidian${NC}"
fi

if ! flatpak install flathub org.telegram.desktop -y; then
    echo -e "${RED}Failed to install Telegram${NC}"
fi

if ! flatpak install flathub com.usebruno.Bruno -y; then
    echo -e "${RED}Failed to install Bruno${NC}"
fi

# Install Brave Browser
info_msg "_________INSTALL BRAVE BROWSER_________"
if ! [ -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ]; then
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
    check_command nala update -y
fi
check_command nala install brave-browser -y

# Install VS Code
info_msg "_________INSTALL VS CODE_________"
if ! wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O "${TEMP_DIR}/vscode.deb"; then
    echo -e "${RED}Failed to download VS Code${NC}"
    handle_error "VS Code download failed"
fi
if ! dpkg -i "${TEMP_DIR}/vscode.deb"; then
    echo -e "${RED}Failed to install VS Code${NC}"
    nala --fix-broken install -y
fi

# Install Chrome
info_msg "_________INSTALL CHROME_________"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "${TEMP_DIR}/chrome.deb" || handle_error "Failed to download Chrome"
dpkg -i "${TEMP_DIR}/chrome.deb" || nala --fix-broken install -y

# Install Redis
info_msg "_________INSTALL REDIS_________"
check_command nala install redis-server -y
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

# Download wallpaper to Downloads
info_msg "_________DOWNLOAD WALLPAPER_________"
wget -P "${ACTUAL_HOME}/Downloads" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/assets/wallpaper.jpg || warning_msg "Failed to download wallpaper"
success_msg "Wallpaper downloaded to Downloads folder. You can set it manually if desired."

# Download setup scripts
info_msg "_________DOWNLOADING SETUP SCRIPTS_________"
SCRIPT_URLS=(
    "https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/scripts/setup-zsh-oh-my-zsh.sh"
    "https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/scripts/setup-vless-xray.sh"
    "https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/scripts/nvidia-display-setup.sh"
)

for url in "${SCRIPT_URLS[@]}"; do
    filename=$(basename "$url")
    wget -P "$SCRIPTS_DIR" "$url" || warning_msg "Failed to download $filename"
    chmod +x "$SCRIPTS_DIR/$filename"
done

success_msg "NVIDIA display setup script has been downloaded to Downloads/scripts folder. Run it later if you have any issues with NVIDIA resolution not showing 1280x1024."

# Clean up the temp directory
info_msg "_________CLEAN UP_________"
rm -rf "$TEMP_DIR"

# Final system cleanup
info_msg "_________FINAL SYSTEM CLEANUP_________"
nala autoremove -y
nala clean -y

# Ask about running setup-vless-xray.sh
read -p "Do you want to run setup-vless-xray.sh? (y/n): " run_vless
if [[ $run_vless == "y" ]]; then
    info_msg "Running setup-vless-xray.sh..."
    sudo -u "$ACTUAL_USER" bash "$SCRIPTS_DIR/setup-vless-xray.sh"
fi

# Ask about running setup-zsh-oh-my-zsh.sh
read -p "Do you want to run setup-zsh-oh-my-zsh.sh? (y/n): " run_zsh
if [[ $run_zsh == "y" ]]; then
    info_msg "Running setup-zsh-oh-my-zsh.sh..."
    sudo -u "$ACTUAL_USER" bash "$SCRIPTS_DIR/setup-zsh-oh-my-zsh.sh"
fi

# Verify services
info_msg "_________SERVICE STATUS CHECK_________"
systemctl status postgresql --no-pager || warning_msg "PostgreSQL service check failed"
systemctl status redis-server --no-pager || warning_msg "Redis service check failed"

# Print final success message
success_msg "Setup completed! Please reboot your system to apply all changes."v
