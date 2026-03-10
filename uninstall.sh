#!/bin/bash
# --- AURORA UNINSTALLER v4.4.7 ---

INSTALL_PATH="$HOME/.aurora-shell_2theme"

echo -e "\033[0;33m⚠️ Uninstalling Aurora Shell...\033[0m"

# 1. Remove Files
if [ -d "$INSTALL_PATH" ]; then
    rm -rf "$INSTALL_PATH"
    echo "✅ Removed Aurora system files."
fi

# 2. Clean Shell Configs
for config in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$config" ]; then
        # Use sed to delete the line containing the aurora source
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/aurora_theme.sh/d' "$config"
        else
            sed -i '/aurora_theme.sh/d' "$config"
        fi
        echo "✅ Cleaned $config"
    fi
done

echo -e "\033[0;32m✨ Aurora has been successfully removed.\033[0m"
