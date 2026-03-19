#!/bin/bash

# --- AURORA-SHELL MASTER v6.1.0 ---
INSTALL_DIR="$HOME/.aurora-shell"
CONFIG_FILE="$INSTALL_DIR/.aurora-shell_settings"
THEME_FILE="$INSTALL_DIR/aurora_theme.sh"
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

mkdir -p "$INSTALL_DIR"

echo -e "\033[1;36m🌟 Aurora-Shell Universal Installer v5.4.9\033[0m"

# --- DEPENDENCY & PLUGIN SYNC ---
sync_system() {
    echo -ne "\033[1;33m🛠️  Syncing Dependencies... \033[0m"
    # Basic Brew Packages
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    brew install figlet lolcat 2>/dev/null

    # Oh-My-Zsh Plugin Injection
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -ne "\033[1;33m📦 Fetching Plugins... \033[0m"
        # Syntax Highlighting
        [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" --quiet
        # Auto Suggestions
        [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
            git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions" --quiet

        # Enable plugins in .zshrc if not already there
        sed -i '' 's/plugins=(/plugins=(zsh-syntax-highlighting zsh-autosuggestions /g' "$HOME/.zshrc" 2>/dev/null
        # Cleanup potential duplicates from sed
        perl -i -pe 's/(zsh-syntax-highlighting|zsh-autosuggestions)\s+\1/$1/g' "$HOME/.zshrc" 2>/dev/null
    fi
    echo -e "\033[1;32mDONE\033[0m"
}
sync_system

# --- CONFIGURATION WIZARD ---
if [ -t 0 ]; then
    echo -e "\n\033[1;32m--- STEP 1: HEADER STYLE ---\033[0m"
    echo "1) Classic (Full Block Art)"
    echo "2) Custom (Figlet Name)"
    read -p "Selection [1-2]: " art_choice < /dev/tty
    
    if [ "$art_choice" == "2" ]; then
        HDR_TYPE="FIGLET"; read -p "✍️  Enter Header Name(leave blank for aurora-shell): " HDR_TEXT < /dev/tty
    else
        HDR_TYPE="BLOCK"; HDR_TEXT="Aurora-Shell"
    fi

    echo -e "\n\033[1;32m--- STEP 2: PERSONALIZATION ---\033[0m"
    read -p "🎂 Birthday (MMDD): " BDAY < /dev/tty
    read -p "🆔 Prompt Name(leave blank for aurora-shell): " P_ID < /dev/tty
    [ -z "$BDAY" ] && BDAY="0000"
    [ -z "$P_ID" ] && P_ID="Aurora-Shell"
else
    HDR_TYPE="BLOCK"; HDR_TEXT="Aurora-Shell"; BDAY="0000"; P_ID="Aurora"
fi

# --- SAVE SETTINGS ---
cat << EOF > "$CONFIG_FILE"
AURORA_VER="6.1.0"
AURORA_HEADER_TYPE="$HDR_TYPE"
AURORA_HEADER_TEXT="$HDR_TEXT"
AURORA_USER_BDAY="$BDAY"
AURORA_ID="$P_ID"
EOF

# --- GENERATE THEME ENGINE ---
cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
SETTING_PATH="$HOME/.aurora-shell/.aurora-shell_settings"
[ ! -f "$SETTING_PATH" ] && return
source "$SETTING_PATH"

get_motd() {
    local today=$(date +%m%d)
    if [ "$today" = "$AURORA_USER_BDAY" ]; then echo "HAPPY BIRTHDAY! 🎂" && return; fi
    case "$today" in
        0101) echo "Happy New Year 🎆" ;;
        0317) echo "St. Patrick's Day 🍀" ;;
        1031) echo "Halloween 🎃" ;;
        1225) echo "Christmas Day 🎄" ;;
        *) echo "" ;; 
    esac
}

Show-AuroraDisplay() {
    window_width="$(tput cols)"
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
    
    battery="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 2>/dev/null || echo '100%')"
    cpu_usage="$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')%"
    stats_line="🔋 $battery | 🧠 CPU: $cpu_usage | 📅 $(date +'%m/%d/%y')"
    padding="$(printf '%*s' $(((window_width-${#stats_line})/2)))"
    echo -e "\033[36m${padding}${stats_line}\033[0m"
    
    m=$(get_motd)
    if [ ! -z "$m" ]; then
        m_pad="$(printf '%*s' $(((window_width-${#m})/2)))"
        echo -e "\033[1;93m${m_pad}✨ $m ✨\033[0m"
    fi
    printf '\033[34m%*s\n\033[0m' "$window_width" '' | tr ' ' '-'
}

rainbow_prompt() {
  SETTING_PATH="$HOME/.aurora-shell/.aurora-shell_settings"
  [ ! -f "$SETTING_PATH" ] && echo -n "Aurora > " && return
  source "$SETTING_PATH"

  # Expand the %n (user) and %m (host) into actual text first
  local raw_text="${AURORA_ID} %n@%m $(date +%H:%M:%S) > "
  local expanded_text=$(print -P "$raw_text")

  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  
  # Apply the rainbow to the EXPANDED text
  for (( j=0; j<${#expanded_text}; j++ )); do
    out+="%{%F{${colors[$(( (j % ${#colors}) + 1 ))]}}%}${expanded_text:$j:1}%{%f%}"
  done
  echo -n "$out"
}

setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'
clear && Show-AuroraDisplay
EOF

# --- INTEGRATE ---
sed -i '' '/aurora_theme.sh/d' ~/.zshrc 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[1;32m✅ v5.4.9 Deployed. Syntax and Suggestions enabled.\033[0m"