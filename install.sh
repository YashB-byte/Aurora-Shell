#!/bin/bash

# --- AURORA-SHELL MASTER v5.3 ---
INSTALL_PATH="$HOME/.aurora-shell"
CONFIG_FILE="$HOME/.aurorasettings"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$INSTALL_PATH"

echo -e "\033[1;36m🌟 Aurora-Shell Universal Installer v5.3\033[0m"

# 1. FRAMEWORK & PLUGINS
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# 2. CONFIGURATION GATE (Interactive vs. CI/CD)
if [ -t 0 ]; then
    echo -e "\n\033[1;32m--- STEP 1: HEADER ART ---\033[0m"
    read -p "1) Classic / 2) Custom [1-2]: " art_choice < /dev/tty
    if [ "$art_choice" == "2" ]; then
        HEADER_TYPE="FIGLET"; read -p "✍️ Name: " HEADER_TEXT < /dev/tty
    else
        HEADER_TYPE="BLOCK"; HEADER_TEXT="Aurora-Shell"
    fi

    echo -e "\n\033[1;32m--- STEP 2: PROMPT STYLE ---\033[0m"
    read -p "1) Default / 2) Sync / 3) Minimal [1-3]: " p_choice < /dev/tty
    case $p_choice in
        1) FINAL_ID="Aurora-Shell" ;;
        2) FINAL_ID="$HEADER_TEXT" ;;
        3) FINAL_ID="" ;;
        *) FINAL_ID="Aurora-Shell" ;;
    esac
    read -rs -p "🔐 Set Master Password (Blank for none): " NEW_PASS < /dev/tty && echo
else
    # CI/CD Defaults to prevent hanging Build #252
    HEADER_TYPE="BLOCK"; HEADER_TEXT="Aurora-Shell"; FINAL_ID="Aurora-Shell"; NEW_PASS=""
fi

# 3. GENERATE CONFIG
cat << EOF > "$CONFIG_FILE"
AURORA_HEADER_TYPE="$HEADER_TYPE"
AURORA_HEADER_TEXT="$HEADER_TEXT"
AURORA_HEADER_VISIBLE="ON"
AURORA_STATS="ON"
AURORA_TIME_VISIBLE="ON"
AURORA_PASS_ENABLED="ON"
AURORA_PWD="$NEW_PASS"
AURORA_ID="$FINAL_ID"
AURORA_MOTD="Welcome to the void."
AURORA_VER="5.3"
EOF

# 4. GENERATE THEME ENGINE (With CPU & Update Logic)
THEME_FILE="$INSTALL_PATH/aurora_theme.sh"
cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
source "$HOME/.aurorasettings"

get_cpu() {
    local cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    echo "${cpu}%"
}

Show-AuroraLock() {
    [ "$AURORA_PASS_ENABLED" = "OFF" ] || [ -z "$AURORA_PWD" ] && return
    echo -e "\033[35m🔐 Locked. Enter Password:\033[0m"
    attempts=0
    while [ $attempts -lt 3 ]; do
        read -rs "input_pass?Password: "
        echo
        if [ "$input_pass" = "$AURORA_PWD" ]; then
            return 0
        else
            attempts=$((attempts + 1))
            [ $attempts -eq 3 ] && kill -9 $$
        fi
    done
}

Show-AuroraDisplay() {
    window_width="$(tput cols)"
    if [ "$AURORA_HEADER_VISIBLE" = "ON" ]; then
        if [ "$AURORA_HEADER_TYPE" = "BLOCK" ]; then
            echo " 
 █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗  
██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗ 
███████║██║   ██║██████╔╝██║   ██║██████╔╝███████║ 
██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██║ 
██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║██║  ██║ 
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ 
                                                   
      ███████╗██╗  ██╗███████╗██╗     ██╗          
      ██╔════╝██║  ██║██╔════╝██║     ██║          
      ███████╗███████║█████╗  ██║     ██║          
      ╚════██║██╔══██║██╔══╝  ██║     ██║          
      ███████║██║  ██║███████╗███████╗███████╗     
      ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝" | lolcat
        else
            figlet -f slant "$AURORA_HEADER_TEXT" | lolcat
        fi
    fi
    
    if [ "$AURORA_STATS" = "ON" ]; then
        battery="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 2>/dev/null || echo '100%')"
        stats_line="📅 $(date +'%m/%d/%y') | 🔋 $battery | 🧠 CPU: $(get_cpu)"
        padding_val=$(( (window_width - ${#stats_line}) / 2 ))
        padding="$(printf '%*s' "$padding_val")"
        echo -e "\033[36m${padding}${stats_line}\033[0m"
        
        motd_padding=$(( (window_width - ${#AURORA_MOTD}) / 2 ))
        motd_pad="$(printf '%*s' "$motd_padding")"
        echo -e "\033[3;90m${motd_pad}\"$AURORA_MOTD\"\033[0m"
        printf '\033[34m%*s\n\033[0m' "$window_width" '' | tr ' ' '-'
    fi
}

shell.aurora() {
    source "$HOME/.aurorasettings"
    case "$1" in
        --update)
            echo -e "🔍 Checking for updates..."
            # Replace URL with your actual Raw URL
            REMOTE_V=$(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell/main/version.txt)
            if [ "$REMOTE_V" != "$AURORA_VER" ] && [ ! -z "$REMOTE_V" ]; then
                echo "🚀 New version $REMOTE_V found! Updating..."
                sed -i '' '/aurora_theme.sh/d' ~/.zshrc
                rm -rf "$HOME/.aurora-shell" "$HOME/.aurorasettings"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/YashB-byte/aurora-shell/main/install.sh)"
            else
                echo "✨ Already up to date."
            fi ;;
        --uninstall)
            sed -i '' '/aurora_theme.sh/d' ~/.zshrc; rm -rf "$HOME/.aurora-shell" "$HOME/.aurorasettings"; echo "🗑️ Removed." ;;
        *)
            clear && Show-AuroraDisplay
            echo "Flags: --status, --update, --time, --header-name, --motd, --pass, --header, --stats, --prompt, --uninstall" ;;
    esac
}
alias aurora="shell.aurora"

rainbow_prompt() {
  source "$HOME/.aurorasettings"
  local clock=""
  [ "$AURORA_TIME_VISIBLE" = "ON" ] && clock="$(date +%H:%M:%S)"
  local text="$AURORA_ID ✨ $clock > "
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  for (( j=0; j<${#text}; j++ )); do
    out+="%{%F{${colors[$(( (j % ${#colors}) + 1 ))]}}%}${text:$j:1}%{%f%}"
  done
  echo -n "$out"
}

setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'
source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
clear && Show-AuroraLock && Show-AuroraDisplay
EOF

# 5. SYNC
sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"
echo -e "\n\033[1;32m✅ v5.3 Installed!\033[0m"