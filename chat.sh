#!/bin/bash
clear
echo -e "\033[1;36m╭─────────────────────────────────────────╮\033[0m"
echo -e "\033[1;36m│  🌌 Auseaia - Local AI Assistant      │\033[0m"
echo -e "\033[1;36m│  Powered by Llama3 via Ollama         │\033[0m"
echo -e "\033[1;36m╰─────────────────────────────────────────╯\033[0m"
echo -e "\033[0;90mCommands: /reset (clear history) | exit (quit)\033[0m\n"

while true; do
    echo -ne "\033[1;32m❯\033[0m "
    read user_input
    
    if [[ "$user_input" == "exit" || "$user_input" == "quit" ]]; then
        echo -e "\n\033[0;36m👋 Goodbye!\033[0m\n"
        break
    fi

    if [[ -z "$user_input" ]]; then
        continue
    fi

    node ~/aurora-shell-2/auseaia.js "$user_input"
done
