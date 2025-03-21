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
    chown -R "${ACTUAL_USER}:${ACTUAL_USER}" "$backup_dir"

    TEXT_COLOR_GREEN='\033[0;32m'
    TEXT_COLOR_RESET='\033[0m'

    DISPLAY_TEXT="The Extensions are successfuly isntalld but you ain't gonna see them once restarted it will appear and automatically updating to latest version after that it will tell you to logout and login then extension will fine. if it's not showing right now dont; worry"

    BOX_WIDTH=100
    BOX_BORDER=$(printf '_%.0s' $(seq 1 $BOX_WIDTH))

    echo -e "${TEXT_COLOR_GREEN}${BOX_BORDER}${TEXT_COLOR_RESET}"
    echo -e "${TEXT_COLOR_GREEN}|| ${DISPLAY_TEXT:0:$(($BOX_WIDTH - 4))} ||${TEXT_COLOR_RESET}"
    echo -e "${TEXT_COLOR_GREEN}${BOX_BORDER}${TEXT_COLOR_RESET}"

    # Update and Upgrade the System
    info_msg "_________UPDATE AND UPGRADE SYSTEM_________"
    apt update || handle_error "Failed to update package lists"
    apt install nala -y || handle_error "Failed to download NALA"

    # Install required dependencies first
    info_msg "_________INSTALL REQUIRED DEPENDENCIES_________"
    nala install -y dbus dbus-x11 || handle_error "Failed to install dbus dependencies"

    # Update and Upgrade the System
    info_msg "_________UPDATE AND UPGRADE SYSTEM_________"
    nala update || handle_error "Failed to update package lists"
    nala upgrade -y || handle_error "Failed to upgrade packages"

    # Install Flatpak and dependencies
    info_msg "_________INSTALL FLATPAK AND DEPENDENCIES_________"
    nala install -y flatpak gnome-software-plugin-flatpak || handle_error "Failed to install Flatpak"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Install Gnome Extensions and Tweaks Packages
    info_msg "_________INSTALL GNOME EXTENSIONS AND TWEAKS_________"
    nala install -y gnome-shell-extensions gnome-tweaks gnome-shell-extension-manager || handle_error "Failed to install GNOME packages"


    # Add sources
    info_msg "_________ADD SOURCES TO APT_________"
    echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" | tee -a /etc/apt/sources.list
    nala update || warning_msg "Failed to update after adding sources"

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
    nala install -y nautilus gnome-calculator gnome-system-monitor || warning_msg "Failed to install some packages"

    # Install utilities
    info_msg "_________INSTALL UTILITIES_________"
    nala install -y wget curl neofetch postgresql postgresql-contrib git preload || warning_msg "Failed to install some utilities"
    systemctl start postgresql || warning_msg "PostgreSQL service failed to start"
    systemctl enable postgresql
    sudo systemctl enable preload

    # Install Warp
    info_msg "_________INSTALL WARP_________"
    sudo -u "$ACTUAL_USER" wget https://app.warp.dev/download?package=deb -O "${TEMP_DIR}/warp.deb" || handle_error "Failed to download Warp"
    dpkg -i "${TEMP_DIR}/warp.deb" || nala --fix-broken install -y

    # Install Apps using Flatpak
    info_msg "_________INSTALL FLATPAK APPS_________"
    flatpak_apps=(
        "com.redis.RedisInsight"
        "md.obsidian.Obsidian"
        "org.telegram.desktop"
        "com.usebruno.Bruno"
    )

    for app in "${flatpak_apps[@]}"; do
        flatpak install flathub "$app" -y || warning_msg "Failed to install $app"
    done

    # Install Brave Browser
    info_msg "_________INSTALL BRAVE BROWSER_________"
    if ! [ -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ]; then
        curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
        nala update || warning_msg "Failed to update after adding Brave repository"
    fi
    nala install -y brave-browser || warning_msg "Failed to install Brave browser"

    # Install VS Code
    info_msg "_________INSTALL VS CODE_________"
    if ! wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O "${TEMP_DIR}/vscode.deb"; then
        warning_msg "Failed to download VS Code"
    else
        if ! dpkg -i "${TEMP_DIR}/vscode.deb"; then
            warning_msg "Failed to install VS Code"
            nala --fix-broken install -y
        fi
    fi

    # Install Chrome
    info_msg "_________INSTALL CHROME_________"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "${TEMP_DIR}/chrome.deb" || warning_msg "Failed to download Chrome"
    dpkg -i "${TEMP_DIR}/chrome.deb" || nala --fix-broken install -y

    # Install Redis
    info_msg "_________INSTALL REDIS_________"
    nala install -y redis-server || warning_msg "Failed to install Redis"
    systemctl start redis-server || warning_msg "Redis service failed to start"
    systemctl enable redis-server

    # Install Mailhog
    info_msg "_________INSTALL MAILHOG_________"
    wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64 -O "${TEMP_DIR}/MailHog" || warning_msg "Failed to download MailHog"
    if [ -f "${TEMP_DIR}/MailHog" ]; then
        chmod +x "${TEMP_DIR}/MailHog"
        mv "${TEMP_DIR}/MailHog" /usr/local/bin/
    fi

    # Install fonts
    info_msg "_________INSTALL FONT_________"
    FONT_DIR="${ACTUAL_HOME}/.fonts"
    mkdir -p "$FONT_DIR"
    chown "${ACTUAL_USER}:${ACTUAL_USER}" "$FONT_DIR"

    sudo -u "$ACTUAL_USER" wget -P "$TEMP_DIR" https://github.com/HenryHendersonDev/personal-setup-scripts/raw/main/assets/fonts.zip || warning_msg "Failed to download fonts"
    if [ -f "$TEMP_DIR/fonts.zip" ]; then
        sudo -u "$ACTUAL_USER" unzip -o "$TEMP_DIR/fonts.zip" -d "$TEMP_DIR/fonts"
        sudo -u "$ACTUAL_USER" mv "$TEMP_DIR"/fonts/*.ttf "$FONT_DIR/" 2>/dev/null || warning_msg "No fonts to move"
        fc-cache -f
    fi

    # Download wallpaper to Downloads
    info_msg "_________DOWNLOAD WALLPAPER_________"
    sudo -u "$ACTUAL_USER" wget -P "${ACTUAL_HOME}/Downloads" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/assets/wallpaper.jpg || warning_msg "Failed to download wallpaper"
    success_msg "Wallpaper downloaded to Downloads folder. You can set it manually if desired."

    # Download setup scripts
    info_msg "_________DOWNLOADING SETUP SCRIPTS_________"
    SCRIPT_URLS=(
        "https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/scripts/setup-zsh-oh-my-zsh.sh"
        "https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/scripts/setup-vless-xray.sh"
        "https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/scripts/nvidia-display-setup.sh"
        "https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/refs/heads/main/scripts/ZSH-plugins.sh"
    )

    for url in "${SCRIPT_URLS[@]}"; do
        filename=$(basename "$url")
        sudo -u "$ACTUAL_USER" wget -P "$SCRIPTS_DIR" "$url" || warning_msg "Failed to download $filename"
        chmod +x "$SCRIPTS_DIR/$filename"
    done

    success_msg "NVIDIA display setup script has been downloaded to Downloads/scripts folder. Run it later if you have any issues with NVIDIA resolution not showing 1280x1024."

    # Clean up the temp directory
    info_msg "_________CLEAN UP_________"
    rm -rf "$TEMP_DIR"

    # Final system cleanup
    info_msg "_________FINAL SYSTEM CLEANUP_________"
    nala autoremove -y
    nala clean
    sudo dpkg --configure -a
    sudo apt remove imagemagick -y

    # Ask about running setup-vless-xray.sh
    read -p "Do you want to run setup-vless-xray.sh? (y/n): " run_vless
    if [[ $run_vless == "y" ]]; then
        info_msg "Running setup-vless-xray.sh..."
        bash "$SCRIPTS_DIR/setup-vless-xray.sh"
    fi

    # Ask about running setup-zsh-oh-my-zsh.sh
    read -p "Do you want to run setup-zsh-oh-my-zsh.sh? (y/n): " run_zsh
    if [[ $run_zsh == "y" ]]; then
        info_msg "Running setup-zsh-oh-my-zsh.sh..."
        bash "$SCRIPTS_DIR/setup-zsh-oh-my-zsh.sh"
    fi

    # Verify services
    info_msg "_________SERVICE STATUS CHECK_________"
    systemctl status postgresql --no-pager || warning_msg "PostgreSQL service check failed"
    systemctl status redis-server --no-pager || warning_msg "Redis service check failed"

    # Print final success message
    MESSAGE="Setup completed! Please reboot your system to apply all changes."

    echo -e "\033[1m$MESSAGE\033[0m"
    for i in {10..1}; do
        echo "Rebooting in $i seconds..."
        sleep 1
    done
    echo "Rebooting now..."
    sudo reboot
