#!/bin/zsh

Show-AuroraLock() {
    [ -z "67" ] && return
    echo -e "\033[35m🔐 Aurora-Shell Lock\033[0m"
    attempts=0
    while [ $attempts -lt 3 ]; do
        read -rs "input_pass?Password: "
        echo
        if [ "$input_pass" = "67" ]; then
            echo -e "\033[32m✅ Access Granted.\033[0m"
            return 0
        else
            attempts=$((attempts + 1))
            [ $attempts -eq 3 ] && kill -9 $$
        fi
    done
}

Show-AuroraDisplay() {
    battery="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1)"
    cpu="$(top -l 1 | grep 'CPU usage' | awk '{print $3}' | sed 's/%//')"
    disk="$(df -h / | awk 'NR==2 {print $4}')"
    window_width="$(tput cols)"
    stats_line="📅 $(date +'%m/%d/%y') | 🔋 $battery | 🧠 CPU: ${cpu}% | 💽 ${disk} Free"
    
    if [ "FIGLET" = "BLOCK" ]; then
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
        figlet -f slant "Yash Behera" | lolcat
    fi
    
    padding_val=$(( (window_width - ${#stats_line}) / 2 ))
    padding="$(printf '%*s' \"$padding_val\")"
    echo -e "\033[36m${padding}${stats_line}\033[0m"
    printf '\033[34m%*s\n\033[0m' "$window_width" '' | tr ' ' '-'
}

clear
Show-AuroraLock
Show-AuroraDisplay

# --- NATIVE RAINBOW ENGINE (LEAK-FREE) ---
rainbow_prompt() {
  local text="> ✨ %~ > "
  local colors=(196 202 226 190 82 46 48 51 45 39 27 21 57 93 129 165 201 199)
  local out=""
  local i=1
  for (( j=0; j<${#text}; j++ )); do
    char="${text:$j:1}"
    color="${colors[$i]}"
    out+="%{%F{$color}%}$char%{%f%}"
    i=$(( (i % ${#colors}) + 1 ))
  done
  echo -n "$out"
}

setopt PROMPT_SUBST
PROMPT='$(rainbow_prompt)'

source "/Users/YashB/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "/Users/YashB/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
