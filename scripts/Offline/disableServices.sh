#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    handle_error "This script must be run as root. Please run with 'sudo'."
fi

sudo systemctl disable bluetooth.service
sudo systemctl disable console-getty.service
sudo systemctl disable debug-shell.service
sudo systemctl disable nftables.service
sudo systemctl disable pg_receivewal@.service
sudo systemctl disable postgresql.service
sudo systemctl disable redis-server@.service
sudo systemctl disable redis-server.service
sudo systemctl disable rtkit-daemon.service
sudo systemctl disable serial-getty@.service
sudo systemctl disable sysstat.service
sudo systemctl disable systemd-boot-check-no-failures.service
sudo systemctl disable systemd-sysext.service
sudo systemctl disable systemd-time-wait-sync.service
sudo systemctl disable upower.service
sudo systemctl disable wpa_supplicant-nl80211@.service
sudo systemctl disable wpa_supplicant-wired@.service
sudo systemctl disable bluetooth.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service
sudo systemctl enable nvidia-suspend.service

sudo apt remove --purge imagemagick gnome-software gnome-contacts gnome-software totem firefox-esr -y
sudo apt autoremove -y
