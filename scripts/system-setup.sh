#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please run with 'sudo'."
    exit 1
fi

# Update and Upgrade the System
sudo apt update && sudo apt upgrade -y

# Install Flatpak and dependencies
sudo apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Gnome Extensions and Tweaks Packages
sudo apt install gnome-shell-extensions gnome-tweaks gnome-shell-extension-manager -y

if [ "$(id -u)" -eq 0 ]; then
    USER=$(logname)
    echo "Running as root, opening links as user $USER"
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
echo "Please install the following extensions from the GNOME Extensions website:"
for link in "${LINKS[@]}"; do
    echo "$link"
done

echo "Press Enter to continue once you have installed the extensions."
echo "Alternatively, press 'o' to open all the extension links in your browser after installation."

read -n 1 -s -r -p "Press 'o' to open the links or press Enter to continue..."

if [[ $REPLY == 'o' ]]; then
    echo "Opening links in your browser..."
    for link in "${LINKS[@]}"; do
        if [ "$(id -u)" -eq 0 ]; then
            sudo -u "$USER" xdg-open "$link"
        else
            xdg-open "$link"
        fi
        sleep 1
    done

    echo "Please ensure you've installed the extensions. Press Enter to continue."
    read -p "Press Enter to continue once you have installed the extensions..."
else
    echo "Please install the extensions before proceeding. Press Enter once done."
    read -p "Press Enter to continue once you have installed the extensions..."
fi

# Create temp directory in Downloads if it doesn't exist
if [ ! -d ~/Downloads/temp ]; then
    mkdir ~/Downloads/temp
    echo "Directory 'temp' created."
else
    echo "Directory 'temp' already exists."
fi
chmod -R 777 ~/Downloads/temp

# Download backup files
wget -P ~/Downloads/temp https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/backups/gnome-backup.txt
wget -P ~/Downloads/temp https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/backups/gnome-extensions-backup.txt

# Restore settings from backups
dconf load /org/gnome/ <~/Downloads/temp/gnome-backup.txt
dconf load /org/gnome/shell/extensions/ <~/Downloads/temp/gnome-extensions-backup.txt

# List GNOME extensions
gnome-extensions list

# Add sources
echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
sudo apt update -y

# Fix Network issues
sudo sed -i '/allow-hotplug eth/s/^/#/' /etc/network/interfaces
sudo sed -i '/iface eth inet dhcp/s/^/#/' /etc/network/interfaces
sudo sed -i 's/^\(managed=\)false/\1true/' /etc/NetworkManager/NetworkManager.conf
sudo systemctl restart NetworkManager
nmcli device status

# Remove unnecessary packages
sudo apt remove --purge gnome-calculator gnome-characters gnome-contacts gnome-software totem gnome-system-monitor nautilus firefox -y
sudo apt clean -y
sudo apt autoremove --purge -y
sudo apt install nautilus gnome-calculator gnome-system-monitor -y

# Install utilities
sudo apt install nala wget curl neofetch postgresql postgresql-contrib git -y
sudo systemctl start postgresql
sudo nala fetch -y

# Install Warp
wget https://app.warp.dev/download?package=deb -O ~/Downloads/temp/warp.deb
sudo dpkg -i ~/Downloads/temp/warp.deb
sudo apt --fix-broken install -y
sudo apt autoremove --purge -y
sudo apt clean -y

# Install Apps using Flatpak
flatpak install flathub com.redis.RedisInsight -y

# Install Brave Browser
sudo apt install curl -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update -y
sudo apt install brave-browser -y

# Install Redis
sudo apt install redis-server -y
sudo systemctl start redis-server

# Install Mailhog
wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64 -O MailHog
chmod +x MailHog
sudo mv MailHog /usr/local/bin/

# Install font
wget -P ~/Downloads/temp https://github.com/HenryHendersonDev/personal-setup-scripts/raw/refs/heads/main/assets/fonts.zip
mkdir -p ~/.fonts
unzip -o ~/Downloads/temp/fonts.zip -d ~/Downloads/temp/fonts
mv ~/Downloads/temp/fonts/*.ttf ~/.fonts/

# Setup wallpaper
wget -P ~/Downloads/temp https://github.com/HenryHendersonDev/personal-setup-scripts/blob/main/assets/wallpaper.jpg
WALLPAPER_PATH="/home/$(whoami)/Downloads/temp/wallpaper.jpg"
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"

# Clean up the temp directory
rm -rf ~/Downloads/temp/

# Final Cleanup
sudo apt autoremove --purge -y
sudo apt autoremove -y
sudo apt remove --purge fonts* -y
sudo apt remove --purge language-pack-* -y
sudo apt autoremove --purge -y

echo "Script executed successfully. All tasks are complete."

# Double-check cleanup success
sudo apt autoremove --purge -y
sudo apt autoremove -y
sudo apt clean -y
