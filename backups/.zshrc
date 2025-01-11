# -------------------------------
# General Configuration
# -------------------------------

# Set the path for Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:/usr/local/node/bin

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

alias cdcode="cd /home/caesar/code"                   # Alias to change directory to your code folder
alias off="sudo shutdown -P now"                      # Alias for shutting down the system immediately
alias bleachbit="flatpak run org.bleachbit.BleachBit" # Alias for shutting down the system immediately

# -------------------------------
# Proxy Configuration Aliases
# -------------------------------

# alias startXray='if [ -f /usr/local/xray/config.json ]; then nohup /usr/local/xray/xray -config /usr/local/xray/config.json > xray.log 2>&1 & echo $! > xray.pid && /usr/local/xray/script/enable-xray-proxy.sh; else echo "File not Found On /usr/local/xray/config.json"; fi'

# alias stopXray='if [ -f xray.pid ] && kill -0 $(cat xray.pid) 2>/dev/null; then kill $(cat xray.pid) && rm -f xray.pid && echo "Process terminated successfully." &&  /usr/local/xray/script/disable-xray-proxy.sh; else echo "No running process found or xray.pid is missing."; fi'

alias startXray='if [ -f /usr/local/xray/config.json ]; then nohup /usr/local/xray/xray -config /usr/local/xray/config.json > /usr/local/xray/xray.log 2>&1 & echo $! > /usr/local/xray/xray.pid && /usr/local/xray/script/enable-xray-proxy.sh; else echo "File not Found On /usr/local/xray/config.json"; fi'

alias stopXray='if [ -f /usr/local/xray/xray.pid ] && kill -0 $(cat /usr/local/xray/xray.pid) 2>/dev/null; then kill $(cat /usr/local/xray/xray.pid) && rm -f /usr/local/xray/xray.pid && echo "Process terminated successfully." &&  /usr/local/xray/script/disable-xray-proxy.sh; else echo "No running process found or /usr/local/xray/xray.pid is missing."; fi'

alias removeProxy='/usr/local/xray/script/disable-xray-proxy.sh'
alias enableProxy='/usr/local/xray/script/enable-xray-proxy.sh'

alias enable-redis="sudo systemctl enable redis-server.service && sudo systemctl start redis-server.service"
alias enable-postgresql="sudo systemctl enable postgresql.service && sudo systemctl start postgresql.service"
# alias enable-ollama="sudo systemctl enable ollama.service && sudo systemctl start ollama.service"

alias clean="bleachbit --clean bash.history deepscan.tmp deepscan.ds_store deepscan.thumbs_db deepscan.vim_swap_user deepscan.vim_swap_root system.cache system.tmp system.trash system.rotated_logs system.recent_documents system.localizations discord.cache vlc.mru"

alias flatpak='http_proxy="http://127.0.0.1:10808" https_proxy="http://127.0.0.1:10808" ftp_proxy="http://127.0.0.1:10808" all_proxy="socks5://127.0.0.1:10808" flatpak'

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
