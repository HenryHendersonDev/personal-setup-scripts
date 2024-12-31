#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please run with 'sudo'."
    exit 1
fi

# Step 1: Install required packages
echo "Installing required packages: zsh, fzf..."
sudo apt update && sudo apt install -y zsh fzf curl git nano

# Step 2: Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Step 3: Clone necessary plugins
echo "Cloning ZSH plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/psprint/zsh-navigation-tools ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-navigation-tools
git clone https://github.com/jamiew/zsh-git-fast ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/gitfast
git clone https://github.com/colorsch/color-man-pages ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/colored-man-pages

# Step 4: Change default shell to zsh
echo "Changing the default shell to ZSH..."
chsh -s $(which zsh)

# Step 5: Configure .zshrc file
echo "Configuring .zshrc file..."

# Backup the existing .zshrc
cp ~/.zshrc ~/.zshrc.backup

cat >~/.zshrc <<'EOF'
# -------------------------------
# General Configuration
# -------------------------------

# Set the path for Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set the theme for the Oh My Zsh prompt
ZSH_THEME="robbyrussell"

# Enable case-sensitive matching for command completion
CASE_SENSITIVE="true"

# Enable/Disable hyphen-insensitive matching for command completion
HYPHEN_INSENSITIVE="true"

# Enable automatic correction of mistyped commands
ENABLE_CORRECTION="true"

# Display waiting dots for command completion
COMPLETION_WAITING_DOTS="true"

# Format for timestamps in history
HIST_STAMPS="mm/dd/yyyy"

# Set the default language environment for the terminal
export LANG=en_US.UTF-8

# -------------------------------
# Plugin and Source Configuration
# -------------------------------

# List of plugins to load for enhancing shell functionality
plugins=(git sudo history encode64 copypath zsh-autosuggestions zsh-syntax-highlighting fzf node zsh-history-substring-search zsh-completions dirhistory zsh-navigation-tools gitfast colored-man-pages)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Set the base directory for FZF (fuzzy finder)
export FZF_BASE=/usr/bin/fzf

# -------------------------------
# Alias Definitions
# -------------------------------

# Common Aliases
alias updatezsh="source ~/.zshrc"  # Reload the Zsh configuration
alias cls="clear && printf 'c'"   # Clear the terminal and reset its state
alias clear="clear && printf 'c'" # Another alias for clearing the terminal

# -------------------------------
# Git-related Aliases
# -------------------------------

alias gs="git status"                                   # Alias for 'git status'
alias g="git"                                           # Alias for 'git'
alias ga="git add ."                                    # Alias for 'git add .' (add all changes)
alias gco="git checkout"                                # Alias for 'git checkout'
alias gd="git diff"                                     # Alias for 'git diff'
alias gb="git branch"                                   # Alias for 'git branch'
alias gpl="git pull"                                    # Alias for 'git pull'
alias gup="git fetch --all && git pull"                 # Alias for 'git fetch' followed by 'git pull'
alias gpush="git push -u origin"                        # Alias for 'git push'
alias gl="git log --oneline --graph --decorate --color" # Alias for 'git log'

# -------------------------------
# Custom Aliases
# -------------------------------

alias cdcode="cd /home/caesar/code" # Alias to change directory to your code folder
alias off="sudo shutdown -P now"    # Alias for shutting down the system immediately

# -------------------------------
# Proxy Configuration Aliases
# -------------------------------

alias startVPN='if [ -f /usr/local/xray/config.json ]; then nohup /usr/local/xray/xray -config /usr/local/xray/config.json > xray.log 2>&1 & echo $! > xray.pid && /home/caesar/Downloads/add_proxy.sh; else echo "File not Found On /usr/local/xray/config.json"; fi'

alias stopVPN='if [ -f xray.pid ] && kill -0 $(cat xray.pid) 2>/dev/null; then kill $(cat xray.pid) && rm -f xray.pid && echo "Process terminated successfully." && /home/caesar/Downloads/remove_proxy.sh; else echo "No running process found or xray.pid is missing."; fi'

# -------------------------------
# Custom Functions
# -------------------------------

# Function to prompt for a commit message and description before making a git commit
function gcommit() {
  echo -n "Enter commit message: "
  read commit_message
  if [[ -z "$commit_message" ]]; then
    echo "Error: Commit message is required!" >&2
    return 1
  fi

  echo -n "Enter description (optional): "
  read commit_description

  # Commit with the message and description if provided
  if [[ -n "$commit_description" ]]; then
    git commit -m "$commit_message" -m "$commit_description"
  else
    git commit -m "$commit_message"
  fi
}

# -------------------------------
# Editor Setup
# -------------------------------

# Set the default editor based on whether the SSH connection is established
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim' # Use vim if connected via SSH
else
  export EDITOR='code' # Use VS Code if not connected via SSH
fi

EOF

# Step 6: Reload ZSH configuration
echo "Reloading ZSH configuration..."
source ~/.zshrc

echo "ZSH setup complete. Please restart your terminal."
