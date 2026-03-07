#!/bin/bash
# --- AURORA SYSTEM INSTALLER v4.1.0 ---
# Optimized for macOS (Zsh) and Linux (Bash)

# 0. VERBOSE SETTINGS
VERBOSE=false
if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    VERBOSE=true
    echo -e "\033[0;33m🛠️ Verbose Mode Enabled\033[0m"
fi

# 1. SET PASSWORD
echo -e "\033[0;35m🌌 Aurora Setup: Set your Terminal Lock Password\033[0m"
# Using /dev/tty ensures read works even when piping from curl
read -rs -p "Set new Terminal Password: " NEW_PASS </dev/tty
echo ""
read -rs -p "Confirm Password: " CONFIRM_PASS </dev/tty
echo ""

if [ "$NEW_PASS" != "$CONFIRM_PASS" ]; then
    echo -e "\033[0;31m❌ Passwords do not match. Installation aborted.\033[0m"
    exit 1
fi

# 2. DEPENDENCY CHECK
echo "🔍 Checking for required tools..."
for tool in lolcat pygmentize git; do
    if ! command -v $tool &>/dev/null; then
        echo "📥 $tool not found. Attempting install..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install $tool || pip3 install $tool
        else
            sudo apt-get install -y $tool || pip3 install $tool
        fi
    fi
done

# 3. FILE SETUP (PURGE & CLONE)
INSTALL_PATH="$HOME/.aurora-shell_2theme"

if [ -d "$INSTALL_PATH" ]; then
    echo "🧹 Purging old Aurora files to ensure a clean sync..."
    rm -rf "$INSTALL_PATH"
fi

mkdir -p "$INSTALL_PATH"

echo "📥 Cloning Aurora Shell..."
# We keep --progress and remove 2>/dev/null so you see exactly what Git is doing
if [ "$VERBOSE" = true ]; then
    git clone --verbose --progress https://github.com/YashB-byte/aurora-shell-2.git "$INSTALL_PATH/repo"
else
    git clone --progress https://github.com/YashB-byte/aurora-shell-2.git "$INSTALL_PATH/repo"
fi

# 4. GENERATE THE THEME FILE
# We write the password and the lock logic into a standalone script
printf 'CORRECT_PASSWORD="%s"\n' "$NEW_PASS" > "$INSTALL_PATH/aurora_theme.sh"

cat << 'EOF' >> "$INSTALL_PATH/aurora_theme.sh"
# --- AURORA SECURITY LOCK ---
echo -e "\033[0;35m🔐 Aurora Terminal Lock\033[0m"
ATTEMPTS=0
while [ $ATTEMPTS -lt 3 ]; do
    # Check if running in Zsh or Bash for the correct 'read' syntax
    if [ -n "$ZSH_VERSION" ]; then 
        read -rs "ui?Password: " </dev/tty
    else 
        read -rsp "Password: " ui </dev/tty
    fi
    echo ""
    
    # Clean input and verify
    if [ "$(echo "$ui" | xargs)" = "$CORRECT_PASSWORD" ]; then
        echo -e "\033[0;32m✅ Access Granted.\033[0m"
        break
    else
        ATTEMPTS=$((ATTEMPTS + 1))
        REMAINING=$((3 - ATTEMPTS))
        if [ $ATTEMPTS -lt 3 ]; then
            echo -e "\033[0;33m❌ Incorrect. $REMAINING attempts left.\033[0m"
        else
            echo -e "\033[0;31m❌ Access Denied. Locking session.\033[0m"
            exit 1
        fi
    fi
done

# --- LOAD AURORA CORE ---
if [ -f "$HOME/.aurora-shell_2theme/repo/aurora_core.sh" ]; then
    source "$HOME/.aurora-shell_2theme/repo/aurora_core.sh"
fi
EOF

# 5. INJECT INTO ZSHRC / BASHRC
SHELL_CONFIG="$HOME/.zshrc"
[[ "$SHELL" == *"bash"* ]] && SHELL_CONFIG="$HOME/.bashrc"

LINE_TO_ADD="source $INSTALL_PATH/aurora_theme.sh"

if ! grep -qF "$LINE_TO_ADD" "$SHELL_CONFIG"; then
    echo "🔗 Linking Aurora to $SHELL_CONFIG..."
    echo "$LINE_TO_ADD" >> "$SHELL_CONFIG"
fi

echo -e "\033[0;32m✨ Aurora shell installed successfully!\033[0m"
read -p "Would you like to activate it now? (y/n): " ACTIVATE </dev/tty
if [[ "$ACTIVATE" =~ ^[Yy]$ ]]; then
    echo "🚀 Activating..."
    source "$SHELL_CONFIG"
else
    echo "👍 No problem! Run 'source $SHELL_CONFIG' whenever you're ready."
fi
