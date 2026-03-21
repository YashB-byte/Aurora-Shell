#!/bin/bash
# --- AURORA-SHELL MASTER v5.6.7 ---
# VERSION: 5.6.7
# AUTHOR: YashB-byte
# REPO: aurora-shell-2
# FEATURE: Dynamic Rainbow Prompt + Seconds + Version Sniffing

INSTALL_DIR="$HOME/.aurora-shell"
CONFIG_FILE="$INSTALL_DIR/.aurora-shell_settings"
THEME_FILE="$INSTALL_DIR/aurora_theme.sh"
REMOTE_URL="https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh"

mkdir -p "$INSTALL_DIR"

echo -e "\033[1;36m🌟 Aurora-Shell Sentinel v5.6.7\033[0m"

# --- VERSION COMPARISON ENGINE ---
check_updates() {
    if [[ "$1" == "--force" ]]; then return 0; fi
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        REMOTE_VER=$(curl -s "$REMOTE_URL" | grep -m1 'VERSION:' | awk '{print $3}')
        
        if [[ "$REMOTE_VER" > "$AURORA_VER" ]]; then
            echo -e "\033[1;33m🚀 Update Available: v$AURORA_VER -> v$REMOTE_VER\033[0m"
            return 0
        else
            echo -e "\033[1;32m✅ Aurora-Shell is up to date (v$AURORA_VER).\033[0m"
            return 1
        fi
    fi
    return 0 
}

# --- DEPENDENCY LOCK ---
sync_env() {
    echo -ne "\033[1;33m🛠️  Locking Environment... \033[0m"
    if ! command -v brew &> /dev/null; then
        if sudo -n true 2>/dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            mkdir -p "$HOME/.brew" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.brew"
            export PATH="$HOME/.brew/bin:$PATH"
            [[ ! $(grep ".brew/bin" "$HOME/.zshrc") ]] && echo 'export PATH="$HOME/.brew/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    fi
    brew install figlet lolcat 2>/dev/null
    echo -e "\033[1;32mREADY\033[0m"
}

# --- INSTALL / UPDATE EXECUTION ---
if check_updates "$1"; then
    sync_env
    
    echo -e "\n\033[1;32m--- CONFIGURATION WIZARD ---\033[0m"
    read -s -p "🔐 Set Terminal PIN (Enter for none): " TERM_PW < /dev/tty; echo ""
    echo "🎨 1) Mega-Block Art  2) Custom Slant Name"
    read -p "Selection: " choice < /dev/tty
    if [ "$choice" == "2" ]; then HDR_MODE="CUSTOM"; read -p "✍️ Header: " HDR_VAL < /dev/tty; else HDR_MODE="BLOCK"; HDR_VAL="Aurora-Shell"; fi
    read -p "🎂 Birthday (MMDD): " BDAY < /dev/tty; read -p "🆔 Prompt ID: " P_ID < /dev/tty

    cat << EOF > "$CONFIG_FILE"
AURORA_VER="5.6.7"
AURORA_PW="$TERM_PW"
AURORA_HDR_MODE="$HDR_MODE"
AURORA_HDR_VAL="$HDR_VAL"
AURORA_USER_BDAY="${BDAY:-0000}"
AURORA_ID="${P_ID:-Aurora-Shell}"
EOF

    # --- GENERATE THEME ENGINE ---
    cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
source "$HOME/.aurora-shell/.aurora-shell_settings"

authenticate_user() {
    local target_pw="${1:-$AURORA_PW}"
    if [[ -z "$target_pw" && -z "$1" ]]; then return; fi
    clear
    echo "
          .---.
         /     \\
        | (00)  |  SYSTEM ENCRYPTED
         \\  ^  /
          '---'
    ╔════════════════════════════════════════╗
    ║     AURORA-SHELL SECURITY TERMINAL     ║
    ╚════════════════════════════════════════╝" | lolcat
    [[ -z "$AURORA_PW" && ! -z "$1" ]] && { echo -ne "\033[1;33m🔐 Set temp PIN: \033[0m"; read -s session_pw; echo ""; target_pw="$session_pw"; }
    while true; do
        echo -ne "\033[1;36m[AUTHENTICATION] Key: \033[0m"; read -s in_pw; echo ""
        [[ "$in_pw" == "$target_pw" ]] && { clear; break; } || echo -e "\033[1;41m DENIED \033[0m"
    done
}

Show-Aurora() {
    source "$HOME/.aurora-shell/.aurora-shell_settings"
    window_width="$(tput cols)"
    if [ "$AURORA_HDR_MODE" = "BLOCK" ]; then
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
        figlet -f slant "$AURORA_HDR_VAL" | lolcat
    fi
    echo -e "\033[36m🔋 $(pmset -g batt | grep -Eo '[0-9]+%' | head -1) | 🧠 CPU: $(top -l 1 | grep 'CPU usage' | awk '{print $3}') | 📅 $(date +'%D')\033[0m"
    printf '\033[34m%.s-\033[0m' {1..$window_width} && echo ""
}

# --- DYNAMIC RAINBOW PROMPT (With Seconds %*) ---
rainbow_prompt() {
  source "$HOME/.aurora-shell/.aurora-shell_settings"
  local raw_text="${AURORA_ID} %n@%m %* > "
  local expanded_text=$(print -P "$raw_text")
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  for (( j=0; j<${#expanded_text}; j++ )); do
    out+="%{%F{${colors[$(( (j % ${#colors}) + 1 ))]}}%}${expanded_text:$j:1}%{%f%}"
  done
  echo -n "$out"
}

aurora() {
    case "$1" in
        --display) Show-Aurora ;;
        --sys) sw_vers && sysctl -n machdep.cpu.brand_string ;;
        --net) echo "IP: $(curl -s ifconfig.me)" ;;
        --weather) curl -s "wttr.in?0pq" ;;
        --lock) authenticate_user "MANUAL" && Show-Aurora ;;
        --update) bash <(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh) ;;
        --uninstall) rm -rf "$HOME/.aurora-shell" && sed -i '' '/aurora_theme/d' ~/.zshrc ;;
        *) echo "Flags: --display, --sys, --net, --weather, --lock, --update, --uninstall" ;;
    esac
}

authenticate_user
setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'
Show-Aurora
EOF

    sed -i '' '/aurora_theme.sh/d' ~/.zshrc 2>/dev/null
    echo "source $THEME_FILE" >> "$HOME/.zshrc"
    echo -e "\n\033[1;32m✅ v5.6.7 Living Rainbow Deployed. Seconds are now active!\033[0m"
fi