#!/bin/bash

# --- AURORA-SHELL MASTER v5.4.3 ---
INSTALL_PATH="$HOME/.aurora-shell"
CONFIG_FILE="$HOME/.aurorasettings"
mkdir -p "$INSTALL_PATH"

echo -e "\033[1;36m🌟 Aurora-Shell Universal Installer v5.4.3\033[0m"

# --- SMART DEPENDENCY ENGINE ---
sync_system() {
    if ! command -v brew &> /dev/null; then
        if sudo -n true 2>/dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            mkdir -p "$HOME/.brew" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.brew"
            export PATH="$HOME/.brew/bin:$PATH"
        fi
    fi
    brew install git figlet lolcat 2>/dev/null
}
sync_system

# --- CONFIGURATION WIZARD (RESTORED CHOICE) ---
if [ -t 0 ]; then
    echo -e "\n\033[1;32m--- STEP 1: HEADER STYLE ---\033[0m"
    echo "1) Classic (Aurora-Shell Block)"
    echo "2) Custom (Your Name via Figlet)"
    read -p "Selection [1-2]: " art_choice < /dev/tty
    
    if [ "$art_choice" == "2" ]; then
        AURORA_HEADER_TYPE="FIGLET"
        read -p "✍️  Enter Display Name: " HEADER_TEXT < /dev/tty
    else
        AURORA_HEADER_TYPE="BLOCK"
        HEADER_TEXT="Aurora-Shell"
    fi

    echo -e "\n\033[1;32m--- STEP 2: PERSONALIZATION ---\033[0m"
    read -p "🎂 Birthday (MMDD): " USER_BDAY < /dev/tty
    [ -z "$USER_BDAY" ] && USER_BDAY="0000"

    read -p "🆔 Prompt Name: " FINAL_ID < /dev/tty
    [ -z "$FINAL_ID" ] && FINAL_ID="Aurora"
else
    AURORA_HEADER_TYPE="BLOCK"; HEADER_TEXT="Aurora-Shell"; USER_BDAY="0000"; FINAL_ID="Aurora"
fi

# --- GENERATE CONFIG ---
cat << EOF > "$CONFIG_FILE"
AURORA_VER="5.4.3"
AURORA_HEADER_TYPE="$AURORA_HEADER_TYPE"
AURORA_HEADER_TEXT="$HEADER_TEXT"
AURORA_USER_BDAY="$USER_BDAY"
AURORA_ID="$FINAL_ID"
EOF

# --- GENERATE THEME ENGINE ---
THEME_FILE="$INSTALL_PATH/aurora_theme.sh"
cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
[ ! -f "$HOME/.aurorasettings" ] && return
source "$HOME/.aurorasettings"

get_cpu() {
    echo "$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')%"
}

get_motd() {
    local today=$(date +%m%d)
    if [ "$today" = "$AURORA_USER_BDAY" ]; then
        echo "HAPPY BIRTHDAY! 🎂"
        return
    fi
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
    
    # RESTORED CHOICE LOGIC
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
    stats_line="🔋 $battery | 🧠 CPU: $(get_cpu)"
    padding="$(printf '%*s' $(((window_width-${#stats_line})/2)))"
    echo -e "\033[36m${padding}${stats_line}\033[0m"
    
    m=$(get_motd)
    if [ ! -z "$m" ]; then
        m_pad="$(printf '%*s' $(((window_width-${#m})/2)))"
        echo -e "\033[1;93m${m_pad}✨ $m ✨\033[0m"
    fi
    printf '\033[34m%*s\n\033[0m' "$window_width" '' | tr ' ' '-'
}

shell.aurora() {
    source "$HOME/.aurorasettings"
    case "$1" in
        --version) echo "📦 Aurora-Shell v$AURORA_VER" ;;
        --update)
            RV=$(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell/main/version.txt)
            if [ "$RV" != "$AURORA_VER" ] && [ ! -z "$RV" ]; then
                aurora --uninstall
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/YashB-byte/aurora-shell/main/install.sh)"
            else echo "✨ Up to date."; fi ;;
        --uninstall)
            sed -i '' '/aurora_theme.sh/d' ~/.zshrc
            rm -rf "$HOME/.aurora-shell" "$HOME/.aurorasettings"
            echo "🗑️  Removed." ;;
        *) clear && Show-AuroraDisplay ;;
    esac
}
alias aurora="shell.aurora"

rainbow_prompt() {
  [ ! -f "$HOME/.aurorasettings" ] && return
  source "$HOME/.aurorasettings"
  local text="${AURORA_ID} @ $(date +%H:%M:%S) > "
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  for (( j=0; j<${#text}; j++ )); do
    out+="%{%F{${colors[$(( (j % ${#colors}) + 1 ))]}}%}${text:$j:1}%{%f%}"
  done
  echo -n "$out"
}

setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'
clear && Show-AuroraDisplay
EOF

# --- FINAL INTEGRATION ---
sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[1;32m✅ v5.4.3 Deployed. Choice logic restored.\033[0m"