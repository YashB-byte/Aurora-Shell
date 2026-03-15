#!/bin/bash

# --- AURORA-SHELL MASTER INSTALLER v4.9.1 ---
# Feature: ANSI Shadow Art + Universal Configuration

# 1. SETUP & DEPENDENCIES
INSTALL_PATH="$HOME/.aurora-shell"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$INSTALL_PATH"

echo -e "\033[1;36m🌟 Aurora-Shell Universal Installer v4.9.1\033[0m"

# Dependency Check (Brew-based)
if [[ "$OSTYPE" == "darwin"* ]]; then
    command -v brew &> /dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for dep in figlet lolcat pygments git; do
        command -v "$dep" &> /dev/null || brew install "$dep"
    done
fi

# 2. DOWNLOAD "ANSI SHADOW" FONT
FONT_FILE="$INSTALL_PATH/ansi_shadow.flf"
if [ ! -f "$FONT_FILE" ]; then
    echo "📥 Downloading Aurora Block Font..."
    curl -s -o "$FONT_FILE" "https://raw.githubusercontent.com/xshrim/figlet-fonts/master/ANSI%20Shadow.flf"
fi

# 3. INTERACTIVE SETUP (For Everyone)
echo -e "\n\033[1;32m--- CONFIGURATION ---\033[0m"

# Header Art Choice
echo -e "\033[36m🎨 Step 1: Header Art Name\033[0m"
read -p "✍️  What name should appear in the BIG header? [Default: Aurora]: " HEADER_TEXT < /dev/tty
[ -z "$HEADER_TEXT" ] && HEADER_TEXT="Aurora"

# Prompt Choice (The "Identity" Fix)
echo -e "\n\033[36m🐚 Step 2: Prompt Style\033[0m"
echo "1) Default    (Aurora-Shell ✨ %~ >)"
echo "2) Header Sync ($HEADER_TEXT ✨ %~ >)"
echo "3) Minimalist (%~ >)"
echo "4) Custom     (Enter your own)"
read -p "Selection [1-4]: " p_choice < /dev/tty

case $p_choice in
    1) FINAL_ID="Aurora-Shell" ;;
    2) FINAL_ID="$HEADER_TEXT" ;;
    3) FINAL_ID="" ;;
    4) read -p "✍️  Enter Custom Prompt Identity: " custom_id < /dev/tty; FINAL_ID="$custom_id" ;;
    *) FINAL_ID="Aurora-Shell" ;;
esac

# Security
echo -e "\n\033[35m🔐 Step 3: Security\033[0m"
read -rs -p "Set Terminal Password (Leave blank for none): " NEW_PASS < /dev/tty && echo

# 4. GENERATE ART CACHE
# We pre-render the ASCII to save loading speed
ASCII_CONTENT=$(figlet -d "$INSTALL_PATH" -f "ansi_shadow" "$HEADER_TEXT")

# 5. GENERATE THEME ENGINE
THEME_FILE="$INSTALL_PATH/aurora_theme.sh"

cat << EOF > "$THEME_FILE"
#!/bin/zsh

Show-AuroraLock() {
    [ -z "$NEW_PASS" ] && return
    echo -e "\033[35m🔐 Locked. Enter Password:\033[0m"
    attempts=0
    while [ \$attempts -lt 3 ]; do
        read -rs "input_pass?Password: "
        echo
        if [ "\$input_pass" = "$NEW_PASS" ]; then
            return 0
        else
            attempts=\$((attempts + 1))
            [ \$attempts -eq 3 ] && kill -9 \$\$
        fi
    done
}

Show-AuroraDisplay() {
    battery="\$(pmset -g batt | grep -Eo '[0-9]+%' | head -1)"
    cpu="\$(top -l 1 | grep 'CPU usage' | awk '{print \$3}' | sed 's/%//')"
    disk="\$(df -h / | awk 'NR==2 {print \$4}')"
    window_width="\$(tput cols)"
    stats_line="📅 \$(date +'%m/%d/%y') | 🔋 \$battery | 🧠 CPU: \${cpu}% | 💽 \${disk} Free"
    
    echo "$ASCII_CONTENT" | lolcat
    
    padding_val=\$(( (window_width - \${#stats_line}) / 2 ))
    padding="\$(printf '%*s' \"\$padding_val\")"
    echo -e "\033[36m\${padding}\${stats_line}\033[0m"
    printf '\033[34m%*s\n\033[0m' "\$window_width" '' | tr ' ' '-'
}

clear
Show-AuroraLock
Show-AuroraDisplay

rainbow_prompt() {
  local id="$FINAL_ID"
  local spacer=""
  [ -n "\$id" ] && spacer=" ✨ "
  local text="\$id\$spacer%~ > "
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  local i=1
  for (( j=0; j<\${#text}; j++ )); do
    char="\${text:\$j:1}"
    color="\${colors[\$i]}"
    out+="%{%F{\$color}%}\$char%{%f%}"
    i=\$(( (i % \${#colors}) + 1 ))
  done
  echo -n "\$out"
}

setopt PROMPT_SUBST
PROMPT='\$(rainbow_prompt)'

# Plugins
[ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
EOF

# 6. SYNC & FINALIZE
sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[1;32m✅ Aurora-Shell v4.9.1 configured for $HEADER_TEXT!\033[0m"