#!/bin/bash
# --- AURORA-SHELL MASTER v6.0 ---
# Bash-only, VS Code safe, POSIX-safe dev tools, hardened theme install

echo "Welcome to the Aurora-Shell installer!"

# --- VS CODE SAFE MODE ---
if [[ "$VSCODE_SHELL_INTEGRATION" == "1" ]]; then
    echo "[Aurora] VS Code detected — skipping interactive install."
    exit 0
fi

# --- PATH CONFIGURATION ---
DATA_DIR="$HOME/.aurora-shell_files"
THEME_FILE="$DATA_DIR/aurora-shell_theme"
CONFIG_FILE="$DATA_DIR/aurora-shell_settings"

mkdir -p "$DATA_DIR"
[ -f "$THEME_FILE" ] && rm "$THEME_FILE"

# --- SYNC ENVIRONMENT ---
sync_env() {
    echo -ne "\033[1;33m🛠️  Syncing Environment... \033[0m"
    if ! command -v brew >/dev/null 2>&1; then
        mkdir -p "$HOME/.brew"
        curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.brew"
        export PATH="$HOME/.brew/bin:$PATH"
    fi
    brew install figlet lolcat pygments >/dev/null 2>&1
    echo -e "\033[1;32mREADY\033[0m"
}

# --- DEV TOOLS BOOTSTRAP (BASH 3.2 SAFE) ---
dev_tools_bootstrap() {
    echo -e "\n\033[1;36m--- DEV TOOLS SETUP (HYBRID MODE) ---\033[0m"

    tools=(
        "Git:git"
        "GitHub_CLI:gh"
        "NodeJS:node"
        "Python3:python@3.14"
        "Java:openjdk"
        "Go:go"
        "Rust:rust"
        "Docker:docker-desktop"
        "AWS_CLI:awscli"
        "Azure_CLI:azure-cli"
    )

    for entry in "${tools[@]}"; do
        name="${entry%%:*}"
        formula="${entry##*:}"

        printf "Install %s? (y/n): " "$name"
        read ans
        if [ "$ans" = "y" ]; then
            case "$name" in
                "Docker")
                    if command -v sudo >/dev/null 2>&1; then
                        brew install --cask docker-desktop
                    else
                        echo "Skipping Docker: sudo not available for this user."
                    fi
                    ;;
                *)
                    brew install "$formula"
                    ;;
            esac
        fi
    done
}

# --- CONFIG WIZARD ---
run_wizard() {
    echo -e "\n\033[1;32m--- AURORA CONFIGURATION WIZARD ---\033[0m"
    [ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

    printf "🔐 Set Terminal PIN (Enter for none): "
    stty -echo
    read NEW_PW
    stty echo
    echo ""

    echo "🎨 Header Style:"
    echo "1) Mega-Block"
    echo "2) Custom Slant"
    printf "Selection: "
    read choice

    if [ "$choice" = "2" ]; then
        HDR_MODE="CUSTOM"
        printf "✍️ Header Name: "
        read HDR_VAL
    else
        HDR_MODE="BLOCK"
        HDR_VAL="Aurora-Shell"
    fi

    printf "🎂 Birthday (MMDD): "
    read BDAY
    printf "🆔 Prompt ID: "
    read P_ID

    cat << EOF > "$CONFIG_FILE"
AURORA_VER="6.0"
AURORA_PW="${NEW_PW:-$AURORA_PW}"
AURORA_HDR_MODE="$HDR_MODE"
AURORA_HDR_VAL="$HDR_VAL"
AURORA_USER_BDAY="${BDAY:-$AURORA_USER_BDAY}"
AURORA_ID="${P_ID:-$AURORA_ID}"
EOF
}

# --- THEME ENGINE ---
generate_theme() {
cat << 'EOF' > "$THEME_FILE"
#!/bin/zsh

CONFIG_FILE="$HOME/.aurora-shell_files/aurora-shell_settings"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE" || return

# --- VS CODE SAFE MODE ---
if [[ "$VSCODE_SHELL_INTEGRATION" == "1" ]]; then
    return
fi

safe_lolcat() {
    if command -v lolcat &> /dev/null; then lolcat; else cat; fi
}

# --- SECURE AUTH ---
authenticate_user() {
    local target_pw="${1:-$AURORA_PW}"
    [[ -z "$target_pw" ]] && return

    trap '' INT
    trap '' TSTP
    trap '' QUIT

    while true; do
        echo -ne "[AUTH] Key: "
        if ! read -s in_pw; then
            echo ""
            echo "DENIED"
            continue
        fi
        echo ""

        if [[ "$in_pw" == "$target_pw" ]]; then
            trap INT
            trap TSTP
            trap QUIT
            clear
            break
        else
            echo "DENIED"
        fi
    done
}

Show-Aurora() {
    source "$HOME/.aurora-shell_files/aurora-shell_settings"
    local cols=$(tput cols)
    local content=""

    if [[ "$AURORA_HDR_MODE" == "BLOCK" ]]; then
        content="
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
     ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝"
    else
        content=$(figlet -f slant "$AURORA_HDR_VAL")
    fi

    local max_w=0
    while IFS= read -r line; do
        (( ${#line} > max_w )) && max_w=${#line}
    done <<< "$content"

    local pad=$(( (cols - max_w) / 2 ))
    (( pad < 0 )) && pad=0

    while IFS= read -r line; do
        printf "%${pad}s%s\n" "" "$line"
    done <<< "$content" | safe_lolcat
}

authenticate_user
Show-Aurora
EOF
}

# --- EXECUTE ---
sync_env
dev_tools_bootstrap
run_wizard
generate_theme

# Clean old references and add new one safely
if ! grep -q 'aurora-shell_theme' "$HOME/.zshrc" 2>/dev/null; then
    echo '[ -f "$HOME/.aurora-shell_files/aurora-shell_theme" ] && source "$HOME/.aurora-shell_files/aurora-shell_theme"' >> "$HOME/.zshrc"
fi

echo -e "\n\033[1;32m✅ Aurora-Shell v6.0 Installed.\033[0m"
