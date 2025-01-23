#!/bin/bash

# Preserve environment variables for proxy settings
export http_proxy="http://127.0.0.1:10808"
export https_proxy="http://127.0.0.1:10808"
export all_proxy="socks5://127.0.0.1:10808"

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

# Update package lists
info_msg "_________UPDATING PACKAGE LISTS_________"
apt update || handle_error "Failed to update package lists."

# Install Flatpak and dependencies if not already installed
info_msg "_________CHECKING AND INSTALLING FLATPAK_________"
if ! command -v flatpak &>/dev/null; then
    info_msg "Flatpak is not installed. Installing..."
    apt install -y flatpak gnome-software-plugin-flatpak || handle_error "Failed to install Flatpak."
else
    success_msg "Flatpak is already installed."
fi

# Add Flathub remote repository if not already added
info_msg "_________ADDING FLATHUB REMOTE REPOSITORY_________"
flatpak remote-list | grep -q flathub || flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Apps using Flatpak
info_msg "_________INSTALLING FLATHUB APPS_________"
flatpak_apps=(
    "com.redis.RedisInsight"
    "md.obsidian.Obsidian"
    "org.telegram.desktop"
    "com.usebruno.Bruno"
    "org.bleachbit.BleachBit"
)

for app in "${flatpak_apps[@]}"; do
    info_msg "Installing $app..."
    flatpak install flathub "$app" -y || warning_msg "Failed to install $app."
done

success_msg "Script execution completed successfully."

#flatpak install flathub md.obsidian.Obsidian com.redis.RedisInsight org.telegram.desktop com.usebruno.Bruno org.bleachbit.BleachBit -y
