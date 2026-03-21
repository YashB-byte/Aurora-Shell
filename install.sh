#!/bin/bash
# --- AURORA-SHELL MASTER v5.7.0 ---
# VERSION: 5.7.0
# ALL LOGIC (UPDATE/UNINSTALL/VERSION CHECK) INSIDE shell.aurora

INSTALL_DIR="$HOME/.aurora-shell"
CONFIG_FILE="$INSTALL_DIR/.aurora-shell_settings"
THEME_FILE="$INSTALL_DIR/aurora_theme.sh"
REMOTE_URL="https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh"

mkdir -p "$INSTALL_DIR"

# --- INITIAL INSTALLER SYNC ---

echo "aurora-shell Version 5.7.0"
sync_env() {
    echo -ne "\033[1;33m🛠️  Syncing Environment... \033[0m"
    if ! command -v brew &> /dev/null; then
        mkdir -p "$HOME/.brew" && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.brew"
        export PATH="$HOME/.brew/bin:$PATH"
    fi
    brew install figlet lolcat 2>/dev/null
    echo -e "\033[1;32mREADY\033[0m"
}

# --- THE WIZARD (Runs on first install or forced update) ---
run_wizard() {
    echo -e "\n\033[1;32m--- AURORA CONFIGURATION WIZARD ---\033[0m"
    read -s -p "🔐 Set Terminal PIN (Enter for none): " TERM_PW < /dev/tty; echo ""
    read -p "🎨 1) Mega-Block 2) Custom Slant: " choice < /dev/tty
    if [ "$choice" == "2" ]; then HDR_MODE="CUSTOM"; read -p "✍️ Header: " HDR_VAL < /dev/tty; else HDR_MODE="BLOCK"; HDR_VAL="Aurora-Shell"; fi
    read -p "🎂 Birthday (MMDD): " BDAY < /dev/tty; read -p "🆔 Prompt ID: " P_ID < /dev/tty

    cat << EOF > "$CONFIG_FILE"
AURORA_VER="5.7.0"
AURORA_PW="$TERM_PW"
AURORA_HDR_MODE="$HDR_MODE"
AURORA_HDR_VAL="$HDR_VAL"
AURORA_USER_BDAY="${BDAY:-0000}"
AURORA_ID="${P_ID:-Aurora}"
EOF
}

# --- THEME ENGINE GENERATION ---
generate_theme() {
    cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh
source "$HOME/.aurora-shell/.aurora-shell_settings"

# -- THE VAULT --
authenticate_user() {
    local target_pw="${1:-$AURORA_PW}"
    if [[ -z "$target_pw" && -z "$1" ]]; then return; fi
    clear
    echo "          .---.
         /     \\
        | (00)  |  SYSTEM ENCRYPTED
         \\  ^  /
          '---'
    ╔════════════════════════════════════════╗
    ║     AURORA-SHELL SECURITY TERMINAL     ║
    ╚════════════════════════════════════════╝" | lolcat
    [[ -z "$AURORA_PW" && ! -z "$1" ]] && { echo -ne "\033[1;33m🔐 Temp PIN: \033[0m"; read -s session_pw; echo ""; target_pw="$session_pw"; }
    while true; do
        echo -ne "\033[1;36m[AUTH] Key: \033[0m"; read -s in_pw; echo ""
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
}

# -- THE COMMAND CENTER (shell.aurora) --
shell.aurora() {
    REMOTE_URL="https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh"
    case "$1" in
        --update)
            echo -e "\033[1;34m🔍 Checking Version...\033[0m"
            REMOTE_VER=$(curl -s "$REMOTE_URL" | grep -m1 'VERSION:' | awk '{print $3}')
            if [[ "$2" == "--force" ]] || [[ "$REMOTE_VER" > "$AURORA_VER" ]]; then
                echo -e "\033[1;33m🚀 Updating: v$AURORA_VER -> v$REMOTE_VER\033[0m"
                bash <(curl -s "$REMOTE_URL") --force
            else
                echo -e "\033[1;32m✅ Already up to date (v$AURORA_VER).\033[0m"
            fi
            ;;
        --uninstall)
            echo -ne "\033[1;31m⚠️  Are you sure? (y/n): \033[0m"
            read choice
            if [[ "$choice" == "y" ]]; then
                rm -rf "$HOME/.aurora-shell"
                sed -i '' '/aurora_theme/d' ~/.zshrc
                echo "Aurora-Shell removed."
            fi
            ;;
        --sys) sw_vers && sysctl -n machdep.cpu.brand_string ;;
        --net) echo "IP: $(curl -s ifconfig.me)" ;;
        --weather) curl -s "wttr.in?0pq" ;;
        --lock) authenticate_user "MANUAL" && Show-Aurora ;;
        *) echo "Flags: --update [--force], --uninstall, --sys, --net, --weather, --lock" ;;
    esac
}
alias aurora="shell.aurora"

# -- RAINBOW PROMPT --
rainbow_prompt() {
  local raw_text="${AURORA_ID} %n@%m %* > "
  local expanded_text=$(print -P "$raw_text")
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  for (( j=0; j<${#expanded_text}; j++ )); do
    out+="%{%F{${colors[$(( (j % ${#colors}) + 1 ))]}}%}${expanded_text:$j:1}%{%f%}"
  done
  echo -n "$out"
}

authenticate_user
setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'
Show-Aurora
EOF
}

# --- EXECUTION ---
sync_env
run_wizard
generate_theme
sed -i '' '/aurora_theme.sh/d' ~/.zshrc 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"
echo -e "\n\033[1;32m✅ v5.7.0 Complete. Shell is now Self-Aware.\033[0m"