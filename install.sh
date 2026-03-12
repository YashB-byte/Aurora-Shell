#!/bin/bash

# --- AURORA SYSTEM INSTALLER (macOS/Zsh) v4.5.0 ---
# Logic: Admin Brew -> User-Home Fallback | Dependency Check | Centered ASCII

# 1. PRE-FLIGHT: HOMEBREW INSTALLATION LOGIC
echo "🔍 Checking for Homebrew..."

if ! command -v brew &> /dev/null; then
    echo "📥 Homebrew missing. Attempting standard (Admin) installation..."
    
    # Try the standard install script first
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo "✅ Standard Brew installed successfully."
        # Initialize for Intel or Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "⚠️ Admin installation failed (likely permissions). Falling back to User-Home install..."
        
        BREW_PATH="$HOME/homebrew"
        if [ ! -d "$BREW_PATH" ]; then
            mkdir -p "$BREW_PATH"
            # Manually extract brew to home directory (No sudo required)
            curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW_PATH"
        fi
        
        # Initialize for current session
        eval "$($BREW_PATH/bin/brew shellenv)"
        
        # Persist path for future sessions in .zprofile
        if ! grep -q "homebrew/bin/brew shellenv" "$HOME/.zprofile"; then
            echo "eval \"\$($BREW_PATH/bin/brew shellenv)\"" >> "$HOME/.zprofile"
        fi
        echo "✅ User-Home Brew initialized."
    fi
else
    echo "✅ Homebrew already present."
fi

# 2. VERIFY DEPENDENCIES
echo "🔍 Verifying Dependencies (Git & lolcat)..."
dependencies=(git lolcat)
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo "📥 Installing $dep..."
        brew install "$dep"
    fi
done

INSTALL_PATH="$HOME/.aurora-shell_2theme"

# 3. CREDENTIALS
if [ -n "$PRESERVED_PASSWORD" ]; then
    PLAIN_PASS="$PRESERVED_PASSWORD"
else
    echo -e "\033[35m🌌 Aurora Setup: Set your Terminal Lock Password\033[0m"
    read -rs -p "Set new Terminal Password: " NEW_PASS
    echo
    read -rs -p "Confirm Password: " CONFIRM_PASS
    echo

    if [ "$NEW_PASS" != "$CONFIRM_PASS" ]; then
        echo -e "\033[31m❌ Passwords do not match!\033[0m"
        exit 1
    fi
    PLAIN_PASS="$NEW_PASS"
fi

# 4. PURGE & CLONE
if [ -d "$INSTALL_PATH" ]; then
    echo "🧹 Purging old Aurora build..."
    rm -rf "$INSTALL_PATH"
fi
mkdir -p "$INSTALL_PATH"

echo "📥 Cloning Aurora Shell v4.5.0..."
REPO_PATH="$INSTALL_PATH/repo"
git clone --progress https://github.com/YashB-byte/aurora-shell-2.git "$REPO_PATH"

# 5. GENERATE THEME ENGINE
THEME_FILE="$INSTALL_PATH/aurora_theme.sh"

cat << EOF > "$THEME_FILE"
#!/bin/bash
CORRECT_PASSWORD="$PLAIN_PASS"

Show-AuroraLock() {
    echo -e "\033[35m🔐 Aurora Terminal Lock\033[0m"
    attempts=0
    while [ \$attempts -lt 3 ]; do
        read -rs -p "Password: " input_pass
        echo
        if [ "\$input_pass" == "\$CORRECT_PASSWORD" ]; then
            echo -e "\033[32m✅ Access Granted.\033[0m"
            return 0
        else
            ((attempts++))
            echo -e "\033[33m❌ Incorrect. \$((3-attempts)) left.\033[0m"
            if [ \$attempts -eq 3 ]; then exit; fi
        fi
    done
}

Show-AuroraDisplay() {
    # System Telemetry
    if command -v pmset &> /dev/null; then
        battery=\$(pmset -g batt | grep -Eo "\d+%" | head -1)
    else
        battery="N/A"
    fi
    
    cpu=\$(top -l 1 | grep "CPU usage" | awk '{print \$3}' | sed 's/%//')
    disk=\$(df -h / | awk 'NR==2 {print \$4}')
    window_width=\$(tput cols)
    
    stats_line="📅 \$(date +'%m/%d/%y') | 🔋 \$battery | 🧠 CPU: \${cpu}% | 💽 \${disk} Free"
    padding_val=\$(( (window_width - \${#stats_line}) / 2 ))
    padding=\$(printf '%*s' "\$padding_val")

    ascii="
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

    echo "\$ascii" | lolcat
    echo -e "\033[36m\$padding\$stats_line\033[0m"
}

clear
Show-AuroraLock
Show-AuroraDisplay
EOF

chmod +x "$THEME_FILE"

# 6. SOURCE IN .ZSHRC
if ! grep -q "source $THEME_FILE" "$HOME/.zshrc"; then
    echo -e "\n# Aurora Shell Theme\nsource $THEME_FILE" >> "$HOME/.zshrc"
fi

echo -e "\033[32m✨ Aurora v4.5.0 Installed!\033[0m"
echo -e "\033[36m🔄 Restart terminal or run 'source ~/.zshrc' to activate.\033[0m"
