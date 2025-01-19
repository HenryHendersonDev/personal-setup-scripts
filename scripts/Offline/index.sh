#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please run with 'sudo'."
    exit 1
fi

# Create the ./data directory if it does not exist
if [[ ! -d "./data" ]]; then
    echo "Creating ./data directory..."
    mkdir -p ./data
fi

# Set full permissions for the ./data directory and its contents
echo "Setting full permissions for ./data and its contents..."
chmod -R 777 ./data

# List the files in ./data to confirm
echo "Contents of ./data:"
ls -l ./data

# Function to display the menu and prompt user for selection
select_script() {
    echo "Select a script to run or type 'q' to quit:"
    PS3="Enter the number of your choice: "

    # Fixed list of scripts
    scripts=(
        "first-boot.sh"
        "zsh-setup.sh"
        "vless.sh"
        "system.sh"
        "extensions.sh"
        "netDownload.sh"
        "flatpak.sh"
        "nvidia.sh"
        "disableServices.sh"
    )

    # Display the available options
    select script in "${scripts[@]}" "Quit"; do
        case $script in
        "Quit")
            echo "Exiting the script."
            break
            ;;
        "")
            echo "Invalid option. Please select a valid number."
            ;;
        *)
            echo "You selected $script."

            # Check if the script exists and run it
            if [[ -f "$script" ]]; then
                bash "$script"
            else
                echo "Script $script not found."
            fi
            break
            ;;
        esac
    done
}

# Main loop: Keep asking user for script to run until they choose 'q' to quit
while true; do
    select_script

    # After running a script, ask if the user wants to run another one
    read -p "Do you want to run another script? (y/n): " choice
    if [[ "$choice" =~ ^[Nn]$ ]]; then
        echo "Exiting the script."
        break
    fi
done
