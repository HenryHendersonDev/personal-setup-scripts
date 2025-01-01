#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root. Please run with 'sudo'.${NC}"
    exit 1
fi

# Update and Upgrade the System
echo -e "${BLUE}_________UPDATE AND UPGRADE SYSTEM_________${NC}"
sudo apt update && sudo apt upgrade -y

# Install Flatpak and dependencies
echo -e "${BLUE}_________INSTALL FLATPAK AND DEPENDENCIES_________${NC}"
sudo apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Gnome Extensions and Tweaks Packages
echo -e "${BLUE}_________INSTALL GNOME EXTENSIONS AND TWEAKS_________${NC}"
sudo apt install gnome-shell-extensions gnome-tweaks gnome-shell-extension-manager -y

if [ "$(id -u)" -eq 0 ]; then
    USER=$(logname)
    echo -e "${GREEN}Running as root, opening links as user $USER${NC}"
else
    USER=$(whoami)
fi

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
echo -e "${YELLOW}_________INSTALL GNOME EXTENSIONS FROM LINKS_________${NC}"
for link in "${LINKS[@]}"; do
    echo -e "${BLUE}$link${NC}"
done

echo -e "${YELLOW}Press Enter to continue once you have installed the extensions.${NC}"
echo -e "${YELLOW}Alternatively, press 'o' to open all the extension links in your browser after installation.${NC}"

read -n 1 -s -r -p "Press 'o' to open the links or press Enter to continue..."

if [[ $REPLY == 'o' ]]; then
    echo -e "${GREEN}Opening links in your browser...${NC}"
    for link in "${LINKS[@]}"; do
        if [ "$(id -u)" -eq 0 ]; then
            sudo -u "$USER" xdg-open "$link"
        else
            xdg-open "$link"
        fi
        sleep 1
    done

    echo -e "${YELLOW}Please ensure you've installed the extensions. Press Enter to continue.${NC}"
    read -p "Press Enter to continue once you have installed the extensions..."
else
    echo -e "${YELLOW}Please install the extensions before proceeding. Press Enter once done.${NC}"
    read -p "Press Enter to continue once you have installed the extensions..."
fi

# Create temp directory in Downloads if it doesn't exist
echo -e "${BLUE}_________CREATE TEMP DIRECTORY_________${NC}"
if [ ! -d ~/Downloads/temp ]; then
    mkdir ~/Downloads/temp
    echo -e "${GREEN}Directory 'temp' created.${NC}"
else
    echo -e "${GREEN}Directory 'temp' already exists.${NC}"
fi
chmod -R 777 ~/Downloads/temp

# Download backup files
echo -e "${BLUE}_________DOWNLOAD BACKUP FILES_________${NC}"
wget -P ~/Downloads/temp https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/backups/gnome-backup.txt
wget -P ~/Downloads/temp https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/backups/gnome-extensions-backup.txt

# Restore settings from backups
echo -e "${BLUE}_________RESTORE SETTINGS FROM BACKUPS_________${NC}"
dconf load /org/gnome/ <~/Downloads/temp/gnome-backup.txt
dconf load /org/gnome/shell/extensions/ <~/Downloads/temp/gnome-extensions-backup.txt

# List GNOME extensions
echo -e "${BLUE}_________LIST GNOME EXTENSIONS_________${NC}"
gnome-extensions list

# Add sources
echo -e "${BLUE}_________ADD SOURCES TO APT_________${NC}"
echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
sudo apt update -y

# Fix Network issues
echo -e "${BLUE}_________FIX NETWORK ISSUES_________${NC}"
sudo sed -i '/allow-hotplug eth/s/^/#/' /etc/network/interfaces
sudo sed -i '/iface eth inet dhcp/s/^/#/' /etc/network/interfaces
sudo sed -i 's/^\(managed=\)false/\1true/' /etc/NetworkManager/NetworkManager.conf
sudo systemctl restart NetworkManager
nmcli device status

# Remove unnecessary packages
echo -e "${BLUE}_________REMOVE UNNECESSARY PACKAGES_________${NC}"
sudo apt remove --purge gnome-calculator gnome-characters gnome-contacts gnome-software totem gnome-system-monitor nautilus firefox -y
sudo apt clean -y
sudo apt autoremove --purge -y
sudo apt install nautilus gnome-calculator gnome-system-monitor -y

# Install utilities
echo -e "${BLUE}_________INSTALL UTILITIES_________${NC}"
sudo apt install nala wget curl neofetch postgresql postgresql-contrib git -y
sudo systemctl start postgresql
sudo nala fetch -y

# Install Warp
echo -e "${BLUE}_________INSTALL WARP_________${NC}"
wget https://app.warp.dev/download?package=deb -O ~/Downloads/temp/warp.deb
sudo dpkg -i ~/Downloads/temp/warp.deb
sudo apt --fix-broken install -y
sudo apt autoremove --purge -y
sudo apt clean -y

# Install Apps using Flatpak
echo -e "${BLUE}_________INSTALL FLATPAK APPS_________${NC}"
flatpak install flathub com.redis.RedisInsight -y

# Install Brave Browser
echo -e "${BLUE}_________INSTALL BRAVE BROWSER_________${NC}"
sudo apt install curl -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update -y
sudo apt install brave-browser -y

# Install Redis
echo -e "${BLUE}_________INSTALL REDIS_________${NC}"
sudo apt install redis-server -y
sudo systemctl start redis-server

# Install Mailhog
echo -e "${BLUE}_________INSTALL MAILHOG_________${NC}"
wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64 -O MailHog
chmod +x MailHog
sudo mv MailHog /usr/local/bin/

# Install font
echo -e "${BLUE}_________INSTALL FONT_________${NC}"
wget -P ~/Downloads/temp https://github.com/HenryHendersonDev/personal-setup-scripts/raw/refs/heads/main/assets/fonts.zip
mkdir -p ~/.fonts
unzip -o ~/Downloads/temp/fonts.zip -d ~/Downloads/temp/fonts
mv ~/Downloads/temp/fonts/*.ttf ~/.fonts/

# Setup wallpaper
echo -e "${BLUE}_________SETUP WALLPAPER_________${NC}"
wget -P ~/Downloads/temp https://github.com/HenryHendersonDev/personal-setup-scripts/blob/main/assets/wallpaper.jpg
WALLPAPER_PATH="/home/$(whoami)/Downloads/temp/wallpaper.jpg"
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"

# Clean up the temp directory
echo -e "${BLUE}_________CLEAN UP TEMP DIRECTORY_________${NC}"
rm -rf ~/Downloads/temp/

# Final Cleanup
echo -e "${BLUE}_________FINAL CLEANUP_________${NC}"
sudo apt autoremove --purge -y
sudo apt autoremove -y
sudo apt remove --purge fonts* -y
sudo apt remove --purge language-pack-* -y
sudo apt autoremove --purge -y

echo -e "${GREEN}Script executed successfully. All tasks are complete.${NC}"

# Double-check cleanup success
echo -e "${BLUE}_________FINAL AUTOREMOVE CHECK_________${NC}"
sudo apt autoremove --purge -y
sudo apt autoremove -y
sudo apt clean -y
