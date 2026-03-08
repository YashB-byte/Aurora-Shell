#!/bin/bash
# --- AURORA SYSTEM INSTALLER v4.4.6 ---
# Centered UI | Conflict Resolution | Zsh-Optimized

# 0. PRE-CLEAN & SETTINGS
VERBOSE=false
[[ "$1" == "-v" || "$1" == "--verbose" ]] && VERBOSE=true
INSTALL_PATH="$HOME/.aurora-shell_2theme"

# 1. SET PASSWORD
if [ -n "$PRESERVED_PASSWORD" ]; then
    echo -e "\033[0;36m🔄 Preserving existing password...\033[0m"
    NEW_PASS="$PRESERVED_PASSWORD"
    CONFIRM_PASS="$PRESERVED_PASSWORD"
else
    echo -e "\033[0;35m🌌 Aurora Setup: Set your Terminal Lock Password\033[0m"
    if [ -t 0 ]; then
        read -rs -p "Set new Terminal Password: " NEW_PASS
        echo ""
        read -rs -p "Confirm Password: " CONFIRM_PASS
        echo ""
    else
        read -rs -p "Set new Terminal Password: " NEW_PASS </dev/tty
        echo ""
        read -rs -p "Confirm Password: " CONFIRM_PASS </dev/tty
        echo ""
    fi
fi

if [[ "$NEW_PASS" != "$CONFIRM_PASS" ]]; then
    echo -e "\033[0;31m❌ Passwords do not match. Installation aborted.\033[0m"
    exit 1
fi

# 2. DEPENDENCY CHECK
echo "🔍 Checking for required tools..."
for tool in lolcat pygmentize git; do
    if ! command -v $tool &>/dev/null; then
        echo "📥 $tool not found. Installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install $tool || pip3 install $tool
        else
            sudo apt-get install -y $tool || pip3 install $tool
        fi
    fi
done

# 3. FILE SETUP (PURGE & CLONE)
if [ -d "$INSTALL_PATH" ]; then
    echo "🧹 Purging old Aurora files to prevent conflicts..."
    rm -rf "$INSTALL_PATH"
fi

mkdir -p "$INSTALL_PATH"

echo "📥 Cloning Aurora Shell..."
if ! git clone --progress https://github.com/YashB-byte/aurora-shell-2.git "$INSTALL_PATH/repo"; then
    echo -e "\033[0;31m❌ Failed to clone repository. Check your internet connection.\033[0m"
    exit 1
fi

# 4. GENERATE THE THEME FILE
printf 'CORRECT_PASSWORD="%s"\n' "$NEW_PASS" > "$INSTALL_PATH/aurora_theme.sh"

cat << 'EOF' >> "$INSTALL_PATH/aurora_theme.sh"
# --- CONFLICT RESOLUTION ---
# This prevents the "parse error near ()" by clearing aliases before function loading
unalias shell.aurora 2>/dev/null
unalias auseaia 2>/dev/null

# --- AURORA SECURITY LOCK ---
echo -e "\033[0;35m🔐 Aurora Terminal Lock\033[0m"
ATTEMPTS=0
while [ $ATTEMPTS -lt 3 ]; do
    if [ -n "$ZSH_VERSION" ]; then 
        read -rs "ui?Password: " </dev/tty
    else 
        read -rsp "Password: " ui </dev/tty
    fi
    echo ""
    
    if [ "$(echo "$ui" | xargs)" = "$CORRECT_PASSWORD" ]; then
        echo -e "\033[0;32m✅ Access Granted.\033[0m"
        break
    else
        ATTEMPTS=$((ATTEMPTS + 1))
        REMAINING=$((3 - ATTEMPTS))
        if [ $ATTEMPTS -lt 3 ]; then
            echo -e "\033[0;33m❌ Incorrect. $REMAINING left.\033[0m"
        else
            echo -e "\033[0;31m❌ Access Denied.\033[0m"
            exit 1
        fi
    fi
done

# --- AURORA DISPLAY LOGIC ---
aurora_display() {
    local date_str=$(date +"%m/%d/%y")
    local battery=$(pmset -g batt 2>/dev/null | grep -Eo "\d+%" | head -1 || echo "N/A")
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local free_space=$(df -h / | awk 'NR==2 {print $4}')
    
    local stats_line="📅 $date_str | 🔋 $battery | 🧠 CPU: $cpu_usage% | 📂 Free: $free_space"
    local separator="------------------------------------------------------------"
    local term_width=$(tput cols)

    echo -e "
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

    printf "%*s\n" $(( (${#stats_line} + term_width) / 2 )) "$stats_line" | lolcat
    printf "%*s\n\n" $(( (${#separator} + term_width) / 2 )) "$separator" | lolcat
}

# Run the display
clear
aurora_display

# --- LOAD REPO COMMANDS & PROMPT ---
# This sources your custom shell prompt and AI assistant commands
[[ -f "$HOME/.aurora-shell_2theme/repo/shell.aurora" ]] && source "$HOME/.aurora-shell_2theme/repo/shell.aurora"
[[ -f "$HOME/.aurora-shell_2theme/repo/auseaia.sh" ]] && source "$HOME/.aurora-shell_2theme/repo/auseaia.sh"
[[ -f "$HOME/.aurora-shell_2theme/repo/aurora_core.sh" ]] && source "$HOME/.aurora-shell_2theme/repo/aurora_core.sh"
EOF

# 5. INJECT INTO CONFIG
SHELL_CONFIG="$HOME/.zshrc"
[[ "$SHELL" == *"bash"* ]] && SHELL_CONFIG="$HOME/.bashrc"
LINE_TO_ADD="source $INSTALL_PATH/aurora_theme.sh"

if ! grep -qF "$LINE_TO_ADD" "$SHELL_CONFIG"; then
    echo "$LINE_TO_ADD" >> "$SHELL_CONFIG"
fi

echo -e "\033[0;32m✨ Aurora shell installed successfully!\033[0m"
read -p "Would you like to activate it now? (y/n): " ACTIVATE </dev/tty
if [[ "$ACTIVATE" =~ ^[Yy]$ ]]; then
    zsh -c "source ~/.zshrc"
else
    echo "👍 Run 'source $SHELL_CONFIG' when ready."
fi
