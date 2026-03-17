#!/bin/bash

# --- AURORA-SHELL MASTER v5.3 ---
INSTALL_PATH="$HOME/.aurora-shell"
CONFIG_FILE="$HOME/.aurorasettings"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$INSTALL_PATH"

echo -e "\033[1;36m🌟 Aurora-Shell Universal Installer v5.3\033[0m"

# 1. FRAMEWORK & PLUGINS
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# 2. HEADER CONFIGURATION
echo -e "\n\033[1;32m--- STEP 1: HEADER ART ---\033[0m"
echo "1) Classic 'AURORA' Block Art"
echo "2) Custom Name (Slant Font)"
read -p "Selection [1-2]: " art_choice < /dev/tty

if [ "$art_choice" == "2" ]; then
    HEADER_TYPE="FIGLET"
    read -p "✍️  Enter Header Name: " HEADER_TEXT < /dev/tty
    [ -z "$HEADER_TEXT" ] && HEADER_TEXT="Aurora"
else
    HEADER_TYPE="BLOCK"
    HEADER_TEXT="Aurora-Shell"
fi

# 3. PROMPT CONFIGURATION
echo -e "\n\033[1;32m--- STEP 2: PROMPT STYLE ---\033[0m"
echo "1) Default    (Aurora-Shell ✨ Time >)"
echo "2) Header Sync ($HEADER_TEXT ✨ Time >)"
echo "3) Minimalist (Time >)"
read -p "Selection [1-3]: " p_choice < /dev/tty

case $p_choice in
    1) FINAL_ID="Aurora-Shell" ;;
    2) FINAL_ID="$HEADER_TEXT" ;;
    3) FINAL_ID="" ;;
    *) FINAL_ID="Aurora-Shell" ;;
esac

# 4. SECURITY
read -rs -p "🔐 Set Master Password (Leave blank for none): " NEW_PASS < /dev/tty && echo

# Create persistent config
cat << EOF > "$CONFIG_FILE"
AURORA_HEADER_TYPE="$HEADER_TYPE"
AURORA_HEADER_TEXT="$HEADER_TEXT"
AURORA_HEADER_VISIBLE="ON"
AURORA_STATS="ON"
AURORA_TIME_VISIBLE="ON"
AURORA_PASS_ENABLED="ON"
AURORA_PWD="$NEW_PASS"
AURORA_ID="$FINAL_ID"
AURORA_MOTD="Welcome to the void."
EOF

# 5. GENERATE THEME ENGINE
THEME_FILE="$INSTALL_PATH/aurora_theme.sh"

cat << EOF > "$THEME_FILE"
#!/bin/zsh

source "$CONFIG_FILE"

Show-AuroraLock() {
    [ "\$AURORA_PASS_ENABLED" = "OFF" ] || [ -z "\$AURORA_PWD" ] && return
    echo -e "\033[35m🔐 Locked. Enter Password:\033[0m"
    attempts=0
    while [ \$attempts -lt 3 ]; do
        read -rs "input_pass?Password: "
        echo
        if [ "\$input_pass" = "\$AURORA_PWD" ]; then
            return 0
        else
            attempts=\$((attempts + 1))
            [ \$attempts -eq 3 ] && kill -9 \$\$
        fi
    done
}

Show-AuroraDisplay() {
    window_width="\$(tput cols)"
    
    if [ "\$AURORA_HEADER_VISIBLE" = "ON" ]; then
        if [ "\$AURORA_HEADER_TYPE" = "BLOCK" ]; then
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
            figlet -f slant "\$AURORA_HEADER_TEXT" | lolcat
        fi
    fi
    
    if [ "\$AURORA_STATS" = "ON" ]; then
        battery="\$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 2>/dev/null || echo '100%')"
        stats_line="📅 \$(date +'%m/%d/%y') | 🔋 \$battery | 🧠 Aurora Active"
        padding_val=\$(( (window_width - \${#stats_line}) / 2 ))
        padding="\$(printf '%*s' \"\$padding_val\")"
        echo -e "\033[36m\${padding}\${stats_line}\033[0m"
        
        motd_padding=\$(( (window_width - \${#AURORA_MOTD}) / 2 ))
        motd_pad="\$(printf '%*s' \"\$motd_padding\")"
        echo -e "\033[3;90m\${motd_pad}\"\$AURORA_MOTD\"\033[0m"
        printf '\033[34m%*s\n\033[0m' "\$window_width" '' | tr ' ' '-'
    fi
}

shell.aurora() {
    source "$CONFIG_FILE"
    case "\$1" in
        --status)
            echo -e "\n\033[1;36m--- SYSTEM STATUS ---\033[0m"
            echo "👤 ID:          \$AURORA_ID"
            echo "🎨 Header:      \$AURORA_HEADER_VISIBLE (\$AURORA_HEADER_TYPE)"
            echo "📊 Stats:       \$AURORA_STATS"
            echo "⏰ Time:        \$AURORA_TIME_VISIBLE"
            echo "🔐 Secure:      \$AURORA_PASS_ENABLED"
            echo "📝 MOTD:        \$AURORA_MOTD"
            echo -e "\033[1;36m---------------------\033[0m" ;;
        --time)
            [ "\$AURORA_TIME_VISIBLE" = "ON" ] && v="OFF" || v="ON"
            sed -i '' "s/^AURORA_TIME_VISIBLE=.*/AURORA_TIME_VISIBLE=\"\$v\"/" "$CONFIG_FILE"
            echo "⏰ Prompt Time: \$v" ;;
        --header-name)
            read "newhn?Enter New Header Name: " && sed -i '' "s/^AURORA_HEADER_TEXT=.*/AURORA_HEADER_TEXT=\"\$newhn\"/" "$CONFIG_FILE"
            sed -i '' "s/^AURORA_HEADER_TYPE=.*/AURORA_HEADER_TYPE=\"FIGLET\"/" "$CONFIG_FILE"
            echo "✅ Header Name Updated." ;;
        --motd)
            read "newm?New MOTD: " && sed -i '' "s|^AURORA_MOTD=.*|AURORA_MOTD=\"\$newm\"|" "$CONFIG_FILE" ;;
        --pass)
            read -rs "newp?New Password: " && sed -i '' "s/^AURORA_PWD=.*/AURORA_PWD=\"\$newp\"/" "$CONFIG_FILE" ;;
        --header)
            [ "\$AURORA_HEADER_VISIBLE" = "ON" ] && v="OFF" || v="ON"
            sed -i '' "s/^AURORA_HEADER_VISIBLE=.*/AURORA_HEADER_VISIBLE=\"\$v\"/" "$CONFIG_FILE" ;;
        --stats)
            [ "\$AURORA_STATS" = "ON" ] && v="OFF" || v="ON"
            sed -i '' "s/^AURORA_STATS=.*/AURORA_STATS=\"\$v\"/" "$CONFIG_FILE" ;;
        --prompt)
            read "newp?New Prompt Identity: " && sed -i '' "s/^AURORA_ID=.*/AURORA_ID=\"\$newp\"/" "$CONFIG_FILE" ;;
        --uninstall)
            sed -i '' '/aurora_theme.sh/d' ~/.zshrc
            rm -rf "$INSTALL_PATH" "$CONFIG_FILE"
            echo "🗑️ Removed." ;;
        *)
            clear && Show-AuroraDisplay
            echo "Flags: --status, --time, --header-name, --motd, --pass, --header, --stats, --prompt, --uninstall" ;;
    esac
    source "$CONFIG_FILE"
}
alias aurora="shell.aurora"

clear
Show-AuroraLock
Show-AuroraDisplay

rainbow_prompt() {
  source "$CONFIG_FILE"
  local id="\$AURORA_ID"
  local clock=""
  [ "\$AURORA_TIME_VISIBLE" = "ON" ] && clock="%D{%H:%M:%S}"
  
  local spacer=" ✨ "
  [ -z "\$id" ] || [ -z "\$clock" ] && [ -z "\$id\$clock" ] && spacer=""
  [ -z "\$id" ] || [ -z "\$clock" ] && spacer=" "

  local text="\$id\$spacer\$clock > "
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
source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
EOF

# 6. SYNC
sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null
echo "source $THEME_FILE" >> "$HOME/.zshrc"

echo -e "\n\033[1;32m✅ v5.3 Installed! Use 'shell.aurora --time' to toggle the clock.\033[0m"