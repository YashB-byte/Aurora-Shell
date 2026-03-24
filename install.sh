#!/bin/bash
# --- AURORA-SHELL MASTER v5.9 ---
# FIXED: VS Code safe mode, secure auth, array syntax, dev-tools, environment

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
    if ! command -v brew &> /dev/null; then
        mkdir -p "$HOME/.brew"
        curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/.brew"
        export PATH="$HOME/.brew/bin:$PATH"
    fi
    brew install figlet lolcat pygments 2>/dev/null
    echo -e "\033[1;32mREADY\033[0m"
}

# --- DEV TOOLS BOOTSTRAP ---
dev_tools_bootstrap() {
    echo -e "\n\033[1;36m--- DEV TOOLS SETUP (HYBRID MODE) ---\033[0m"

    declare -A tools=(
        ["Git"]="git"
        ["GitHub_CLI"]="gh"
        ["NodeJS"]="node"
        ["Python3"]="python3"
        ["Java"]="openjdk"
        ["Go"]="go"
        ["Rust"]="rustc"
        ["Docker"]="docker"
        ["AWS_CLI"]="aws"
        ["Azure_CLI"]="az"
        ["PostgreSQL"]="postgresql"
        ["MongoDB"]="mongodb-community"
        ["Redis"]="redis"
        ["VSCode"]="visual-studio-code"
        ["Rosetta"]="softwareupdate"
    )

    for t in "${!tools[@]}"; do
        read -p "Install $t? (y/n): " ans < /dev/tty
        if [[ "$ans" == "y" ]]; then
            case "$t" in
                "VSCode") brew install --cask visual-studio-code ;;
                "Docker") brew install --cask docker ;;
                "MongoDB") brew tap mongodb/brew && brew install mongodb-community ;;
                "Redis") brew install redis ;;
                "PostgreSQL") brew install postgresql ;;
                "Rosetta") softwareupdate --install-rosetta --agree-to-license ;;
                *) brew install "${tools[$t]}" ;;
            esac
        fi
    done
}

# --- CONFIG WIZARD ---
run_wizard() {
    echo -e "\n\033[1;32m--- AURORA CONFIGURATION WIZARD ---\033[0m"
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

    read -s -p "🔐 Set Terminal PIN (Enter for none): " NEW_PW < /dev/tty; echo ""

    echo "🎨 Header Style:"
    echo "1) Mega-Block"
    echo "2) Custom Slant"
    read -p "Selection: " choice < /dev/tty

    if [[ "$choice" == "2" ]]; then
        HDR_MODE="CUSTOM"
        read -p "✍️ Header Name: " HDR_VAL < /dev/tty
    else
        HDR_MODE="BLOCK"
        HDR_VAL="Aurora-Shell"
    fi

    read -p "🎂 Birthday (MMDD): " BDAY < /dev/tty
    read -p "🆔 Prompt ID: " P_ID < /dev/tty

    cat << EOF > "$CONFIG_FILE"
AURORA_VER="5.9"
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
source "$HOME/.aurora-shell_files/aurora-shell_settings"

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

    # Disable Ctrl+C, Ctrl+Z, Ctrl+\
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

# --- HEADER DISPLAY ---
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

sed -i '' '/aurora-shell_theme/d' ~/.zshrc 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[1;32m✅ Aurora-Shell v5.9 Installed.\033[0m"
