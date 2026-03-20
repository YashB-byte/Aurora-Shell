#!/bin/bash
# --- AURORA-SHELL MASTER v5.6.5 ---
# VERSION: 5.6.5
# AUTHOR: YashB-byte
# REPO: aurora-shell-2

INSTALL_DIR="$HOME/.aurora-shell"
CONFIG_FILE="$INSTALL_DIR/.aurora-shell_settings"
THEME_FILE="$INSTALL_DIR/aurora_theme.sh"
REMOTE_URL="https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh"

mkdir -p "$INSTALL_DIR"

echo -e "\033[1;36m🌟 Aurora-Shell Sentinel Installer v5.6.5\033[0m"

# --- VERSION COMPARISON ENGINE ---
check_updates() {
    if [[ "$1" == "--force" ]]; then return 0; fi
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        # Peek at remote version without executing
        REMOTE_VER=$(curl -s "$REMOTE_URL" | grep -m1 'VERSION:' | awk '{print $3}')
        
        if [[ "$REMOTE_VER" > "$AURORA_VER" ]]; then
            echo -e "\033[1;33m🚀 Update Available: v$AURORA_VER -> v$REMOTE_VER\033[0m"
            return 0
        else
            echo -e "\033[1;32m✅ Local version (v$AURORA_VER) is the latest.\033[0m"
            return 1
        fi
    fi
    return 0 # Fresh Install
}

# --- DEPENDENCY & PATH LOCK ---
sync_env() {
    echo -ne "\033[1;33m🛠️  Checking Environment... \033[0m"
    if ! command -v brew &> /dev/null; then
        if sudo -n true 2>/dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Standard User Homebrew Lock
            mkdir -p "$HOME/.brew" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.brew"
            export PATH="$HOME/.brew/bin:$PATH"
            [[ ! $(grep ".brew/bin" "$HOME/.zshrc") ]] && echo 'export PATH="$HOME/.brew/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    fi
    brew install figlet lolcat 2>/dev/null
    echo -e "\033[1;32mREADY\033[0m"
}

# --- INSTALLATION / UPDATE EXECUTION ---
if check_updates "$1"; then
    sync_env
    
    # Wizard Data
    echo -e "\n\033[1;32m--- CONFIGURATION WIZARD ---\033[0m"
    read -s -p "🔐 Set/Change Terminal PIN (Enter to skip): " TERM_PW < /dev/tty; echo ""
    echo "🎨 1) Mega-Block Art  2) Custom Slant Name"
    read -p "Selection: " choice < /dev/tty
    if [ "$choice" == "2" ]; then HDR_MODE="CUSTOM"; read -p "✍️ Header: " HDR_VAL < /dev/tty; else HDR_MODE="BLOCK"; HDR_VAL="Aurora-Shell"; fi
    read -p "🎂 Birthday (MMDD): " BDAY < /dev/tty; read -p "🆔 Prompt ID: " P_ID < /dev/tty

    # Write Settings
    cat << EOF > "$CONFIG_FILE"
AURORA_VER="5.6.5"
AURORA_PW="$TERM_PW"
AURORA_HDR_MODE="$HDR_MODE"
AURORA_HDR_VAL="$HDR_VAL"
AURORA_USER_BDAY="${BDAY:-0000}"
AURORA_ID="${P_ID:-Aurora-Shell}"
EOF

    # Generate Theme Engine
    cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
source "$HOME/.aurora-shell/.aurora-shell_settings"

# -- THE VAULT --
authenticate_user() {
    local target_pw="${1:-$AURORA_PW}"
    if [[ -z "$target_pw" && -z "$1" ]]; then return; fi
    clear
    echo "
          .---.
         /     \\
        | (00)  |  SYSTEM ENCRYPTED
         \\  -  /
          '---'
    ╔════════════════════════════════════════╗
    ║       AURORA SECURITY TERMINAL         ║
    ╚════════════════════════════════════════╝" | lolcat
    [[ -z "$AURORA_PW" && ! -z "$1" ]] && { echo -ne "\033[1;33m🔐 Set Temp PIN: \033[0m"; read -s session_pw; echo ""; target_pw="$session_pw"; }
    while true; do
        echo -ne "\033[1;36m[AUTHENTICATION] Key: \033[0m"; read -s in_pw; echo ""
        [[ "$in_pw" == "$target_pw" ]] && { clear; break; } || echo -e "\033[1;41m DENIED \033[0m"
    done
}

# -- DISPLAY --
Show-Aurora() {
    source "$HOME/.aurora-shell/.aurora-shell_settings"
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
    printf '\033[34m%.s-\033[0m' {1..$(tput cols)} && echo ""
}

# -- FLAGS --
aurora() {
    case "$1" in
        --display) Show-Aurora ;;
        --sys) sw_vers && sysctl -n machdep.cpu.brand_string ;;
        --net) echo "External IP: $(curl -s ifconfig.me)" ;;
        --weather) curl -s "wttr.in?0pq" ;;
        --lock) authenticate_user "MANUAL" && Show-Aurora ;;
        --update) bash <(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh) ;;
        --force-update) bash <(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh) --force ;;
        --uninstall) rm -rf "$HOME/.aurora-shell" && sed -i '' '/aurora_theme/d' ~/.zshrc && echo "Uninstalled." ;;
        *) echo "1) --display 2) --sys 3) --net 4) --weather 5) --lock 6) --update 7) --uninstall" ;;
    esac
}

# -- INIT --
authenticate_user
setopt PROMPT_SUBST
PROMPT='%{%F{196}%}${AURORA_ID} %{%F{202}%}%n@%m %{%F{226}%}%T %{%F{82}%}> %{%f%}'
Show-Aurora
EOF

    # Clean ZSHRC and Inject
    sed -i '' '/aurora_theme.sh/d' ~/.zshrc 2>/dev/null
    echo "source $THEME_FILE" >> "$HOME/.zshrc"
    echo -e "\n\033[1;32m✅ v5.6.5 Sentinel Active. Restart terminal or 'source ~/.zshrc'\033[0m"
fi