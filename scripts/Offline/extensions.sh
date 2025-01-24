#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root. Please run with 'sudo'."
    exit 1
fi

# Get the actual user who invoked sudo
ACTUAL_USER=$(logname || who am i | awk '{print $1}')
ACTUAL_HOME=$(eval echo ~${ACTUAL_USER})

# Install required dependencies
echo "_________INSTALL REQUIRED DEPENDENCIES_________"
apt install -y dbus dbus-x11 unzip || { echo "Failed to install required dependencies."; exit 1; }

# Create extensions directory in the user's home directory
EXTENSIONS_DIR="${ACTUAL_HOME}/.local/share/gnome-shell/extensions"
mkdir -p "$EXTENSIONS_DIR"
chown -R "${ACTUAL_USER}:${ACTUAL_USER}" "$EXTENSIONS_DIR"

# Extract extensions to the user's extensions directory
echo "_________EXTRACTING EXTENSIONS_________"
unzip -o "./data/extension.zip" -d "./data/extensions" || { echo "Failed to unzip extensions."; exit 1; }
for ext in ./data/extensions/*.shell-extension.zip; do
    sudo -u "$ACTUAL_USER" unzip -o "$ext" -d "$EXTENSIONS_DIR" || { echo "Failed to extract extension: $ext"; exit 1; }
done
chown -R "${ACTUAL_USER}:${ACTUAL_USER}" "$EXTENSIONS_DIR"

# Enable extensions using gnome-extensions CLI
echo "_________ENABLING EXTENSIONS_________"
sudo -u "$ACTUAL_USER" bash -c "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$(id -u $ACTUAL_USER)/bus\" && {
    gnome-extensions enable just-perfection-desktop@just-perfection
    gnome-extensions enable compiz-windows-effect@hermes83.github.com
    gnome-extensions enable blur-my-shell@aunetx
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    gnome-extensions enable Vitals@CoreCoding.com
    gnome-extensions enable compiz-alike-magic-lamp-effect@hermes83.github.com
    gnome-extensions enable clipboard-indicator@tudmotu.com
}" || { echo "Failed to enable some extensions. Check permissions."; }

# Restore GNOME settings from backup if available
echo "_________RESTORE SETTINGS FROM BACKUPS_________"
if [ -f "./data/gnome-backup.txt" ]; then
    sudo -u "$ACTUAL_USER" bash -c "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$(id -u $ACTUAL_USER)/bus\" && \
    dconf load /org/gnome/ < ./data/gnome-backup.txt && echo \"GNOME settings restored.\""
else
    echo "gnome-backup.txt not found in ./data directory - skipping GNOME settings restore."
fi

if [ -f "./data/gnome-extensions-backup.txt" ]; then
    sudo -u "$ACTUAL_USER" bash -c "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$(id -u $ACTUAL_USER)/bus\" && \
    dconf load /org/gnome/shell/extensions/ < ./data/gnome-extensions-backup.txt && echo \"Extension settings restored.\""
else
    echo "gnome-extensions-backup.txt not found in ./data directory - skipping extension settings restore."
fi

# List installed extensions
echo "_________LIST GNOME EXTENSIONS_________"
sudo -u "$ACTUAL_USER" bash -c "export DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$(id -u $ACTUAL_USER)/bus\" && gnome-extensions list"

# Completion message
echo "____________________________________________________________________________________________________"
echo "|| The Extensions are successfully installed but you won't see them immediately after restart. They ||"
echo "|| will appear and automatically update to the latest version. After that, you'll be prompted to   ||"
echo "|| logout and login, then the extensions will work fine. If they're not showing right now, don't    ||"
echo "|| worry!                                                                                          ||"
echo "____________________________________________________________________________________________________"

