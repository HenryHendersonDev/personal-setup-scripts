#!/bin/bash

read -p "Enter your username: " username

# Check if username is empty
if [ -z "$username" ]; then
    echo "Error: No username entered. Please run the script again and provide a valid username."
    exit 1
fi

home_dir="/home/$username"

if [ ! -d "$home_dir" ]; then
    echo "Error: No user found with the username '$username'. Please check the username and try again."
    exit 1
fi

plugin_dir="$home_dir/.oh-my-zsh/custom/plugins"

if [ ! -d "$plugin_dir" ]; then
    echo "Creating plugin directory at $plugin_dir..."
    mkdir -p "$plugin_dir"
fi

clone_repo() {
    local repo_url=$1
    local target_dir=$2

    if [ ! -d "$target_dir" ]; then
        echo "Cloning repository from $repo_url to $target_dir..."
        git clone "$repo_url" "$target_dir"
    else
        echo "Repository already cloned: $target_dir"
    fi
}

# List of repositories to clone
clone_repo "https://github.com/zsh-users/zsh-autosuggestions" "$plugin_dir/zsh-autosuggestions"
clone_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$plugin_dir/zsh-syntax-highlighting"
clone_repo "https://github.com/zsh-users/zsh-history-substring-search" "$plugin_dir/zsh-history-substring-search"
clone_repo "https://github.com/zsh-users/zsh-completions" "$plugin_dir/zsh-completions"
clone_repo "https://github.com/psprint/zsh-navigation-tools" "$plugin_dir/zsh-navigation-tools"

echo "All plugins are set up successfully!"
