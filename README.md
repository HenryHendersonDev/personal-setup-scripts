# Personal Setup Scripts for Debian & GNOME

This repository contains custom setup scripts for configuring and optimizing a Debian-based system with GNOME. These scripts are specifically designed for personal use and tailored to the latest versions of Debian and GNOME. They can also be used with other Debian-based distributions that utilize GNOME.

⚠️ **Disclaimer**:  
These scripts are provided for personal use only. **Use at your own risk**. I am not responsible for any issues or damages caused by running these scripts. Please review the content carefully before running them.

## Folder Structure

The repository contains the following folder structure:

```
scripts/
├── assets/
│   ├── fonts.zip
│   └── wallpaper.jpg
├── backups/
│   ├── gnome-backup.txt
│   └── gnome-extensions-backup.txt
├── scripts/
│   ├── nvidia-display-setup.sh
│   ├── proxy/
│   │   ├── disable-xray-proxy.sh
│   │   └── enable-xray-proxy.sh
│   ├── setup-vless-xray.sh
│   ├── setup-zsh-oh-my-zsh.sh
│   └── system-setup.sh
```

### Folder Details:
- **assets/**: Contains assets like fonts and wallpapers.
- **backups/**: Contains backup files for GNOME settings and extensions.
- **scripts/**: Contains the core setup scripts for configuring your system.

## Script Details

### 1. **`nvidia-display-setup.sh`**
This script configures the NVIDIA display settings by generating and writing a custom `xorg.conf` file for your system.

### 2. **`setup-vless-xray.sh`**
This script installs and configures Xray with VLESS proxy settings. It also downloads necessary proxy enable/disable scripts for easy use.

### 3. **`setup-zsh-oh-my-zsh.sh`**
This script installs Zsh, sets up Oh My Zsh, and configures essential plugins and customizations to enhance your terminal experience.

### 4. **`system-setup.sh`**
This script performs system-wide setup tasks such as installing Flatpak, GNOME extensions, and other utilities, as well as configuring system settings and restoring backups.

### 5. **`enable-xray-proxy.sh`**
This script enables proxy settings for the Xray VLESS proxy by modifying system configuration files. It sets the system and session-level proxy variables, updates GNOME system proxy settings, and configures proxy settings in `/etc/environment`, `~/.zshrc`, and `/etc/apt/apt.conf.d/95proxies`.

### 6. **`disable-xray-proxy.sh`**
This script disables the Xray VLESS proxy by removing system proxy settings, unsetting environment variables, and clearing proxy configurations from `/etc/environment`, `~/.zshrc`, and `/etc/apt/apt.conf.d/95proxies`.

## Usage

1. Clone or download the repository.
2. Navigate to the `scripts/` folder.
3. Review the scripts and backup your system before running them.
4. Run the scripts in sequence or individually as needed. Most of these require root privileges, so use `sudo` where necessary.

For example, to run the **NVIDIA display setup**, use:
```bash
sudo bash nvidia-display-setup.sh
```

To enable the **Xray proxy**, use:
```bash
sudo bash scripts/proxy/enable-xray-proxy.sh
```

To disable the **Xray proxy**, use:
```bash
sudo bash scripts/proxy/disable-xray-proxy.sh
```

## Supported Distributions

- **Debian-based systems (latest Debian releases)**
- **GNOME Desktop Environment**

While these scripts are tailored for the latest Debian and GNOME setups, they should work with other Debian-based distributions using GNOME.

## Additional Notes

- These scripts are designed for **personal use** and assume a certain level of system familiarity. If you're unfamiliar with system setup or modifications, **use caution**.
- **Backup** your system before executing any of these scripts.
- The scripts are **not officially supported**. Use them as-is and at your own discretion.
