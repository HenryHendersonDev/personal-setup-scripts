#!/bin/bash

# Define color codes - You can remove this if you want to use the same color definitions in main script
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Error handling function - You can remove this if you want to use the same function in main script
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Success message function - You can remove this if you want to use the same function in main script
success_msg() {
    echo -e "${GREEN}$1${NC}"
}

# Info message function - You can remove this if you want to use the same function in main script
info_msg() {
    echo -e "${BLUE}$1${NC}"
}

# Warning message function - You can remove this if you want to use the same function in main script
warning_msg() {
    echo -e "${YELLOW}$1${NC}"
}

# Get the actual user who invoked sudo - You can remove this if you assume ACTUAL_USER and TEMP_DIR are set by main script
ACTUAL_USER=$(logname || who am i | awk '{print $1}')
ACTUAL_HOME=$(eval echo ~${ACTUAL_USER})
TEMP_DIR="${ACTUAL_HOME}/Downloads/temp"

# Download and install extensions
info_msg "_________DOWNLOADING AND INSTALLING GNOME EXTENSIONS_________"
# Download as the actual user
sudo -u "$ACTUAL_USER" wget -P "$TEMP_DIR" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/assets/extension.zip || handle_error "Failed to download extensions"

# Create extensions directory and set permissions
mkdir -p "$TEMP_DIR/extensions"
chown "${ACTUAL_USER}:${ACTUAL_USER}" "$TEMP_DIR/extensions"

# Unzip as the actual user
sudo -u "$ACTUAL_USER" unzip -o "$TEMP_DIR/extension.zip" -d "$TEMP_DIR/extensions" || handle_error "Failed to unzip extensions"

# Set proper permissions
chmod -R 755 "$TEMP_DIR/extensions"
chown -R "${ACTUAL_USER}:${ACTUAL_USER}" "$TEMP_DIR/extensions"

# Install and enable extensions as the actual user
cd "$TEMP_DIR/extensions" || handle_error "Failed to access extensions directory"
for ext in *.shell-extension.zip; do
    if [ -f "$ext" ]; then
        sudo -u "$ACTUAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $ACTUAL_USER)/bus" gnome-extensions install --force "$ext" || warning_msg "Failed to install extension: $ext"
    fi
done

# Enable extensions with proper dbus session
sudo -u "$ACTUAL_USER" bash -c "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$(id -u $ACTUAL_USER)/bus\" && {
gnome-extensions enable just-perfection-desktop@just-perfection
gnome-extensions enable compiz-windows-effect@hermes83.github.com
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable Vitals@CoreCoding.com
gnome-extensions enable compiz-alike-magic-lamp-effect@hermes83.github.com
gnome-extensions enable clipboard-indicator@tudmotu.com
}"

# Download backup files with error checking
info_msg "_________DOWNLOAD BACKUP FILES_________"
sudo -u "$ACTUAL_USER" wget -P "$TEMP_DIR" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/backups/gnome-backup.txt || handle_error "Failed to download gnome-backup.txt"
sudo -u "$ACTUAL_USER" wget -P "$TEMP_DIR" https://raw.githubusercontent.com/HenryHendersonDev/personal-setup-scripts/main/backups/gnome-extensions-backup.txt || handle_error "Failed to download gnome-extensions-backup.txt"

# Restore settings from backups with proper dbus session
info_msg "_________RESTORE SETTINGS FROM BACKUPS_________"
sudo -u "$ACTUAL_USER" bash -c "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$(id -u $ACTUAL_USER)/bus\" && {
if [ -f \"$TEMP_DIR/gnome-backup.txt\" ]; then
    dconf load /org/gnome/ < \"$TEMP_DIR/gnome-backup.txt\"
fi
if [ -f \"$TEMP_DIR/gnome-extensions-backup.txt\" ]; then
    dconf load /org/gnome/shell/extensions/ < \"$TEMP_DIR/gnome-extensions-backup.txt\"
fi
}"

# List GNOME extensions
info_msg "_________LIST GNOME EXTENSIONS_________"
sudo -u "$ACTUAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $ACTUAL_USER)/bus" gnome-extensions list
