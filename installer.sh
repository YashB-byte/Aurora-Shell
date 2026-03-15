#!/bin/bash

# --- AURORA-SHELL UNIX INSTALLER v4.9.2 ---
# Goal: Find the theme file and link it to ZSH automatically.

INSTALL_DIR="$HOME/.aurora-shell"
mkdir -p "$INSTALL_DIR"

echo -e "\033[1;36m🌈 Aurora-Shell Unix Setup\033[0m"

# 1. SMART DISCOVERY
# Looks for aurora_theme.sh in the current folder or the parent folder
THEME_SOURCE=$(find . -maxdepth 2 -name "aurora_theme.sh" | head -n 1)

if [ -z "$THEME_SOURCE" ]; then
    echo -e "\033[1;31m❌ Error: aurora_theme.sh not found!\033[0m"
    echo "Make sure you are running this script from inside the aurora-shell folder."
    exit 1
fi

echo "📦 Found theme engine at: $THEME_SOURCE"

# 2. INSTALLATION
# Move the theme to the hidden config folder
cp "$THEME_SOURCE" "$INSTALL_DIR/aurora_theme.sh"
chmod +x "$INSTALL_DIR/aurora_theme.sh"

# 3. ZSH INTEGRATION
# Remove any old references to prevent double-loading
if [ -f "$HOME/.zshrc" ]; then
    sed -i '' '/aurora_theme.sh/d' "$HOME/.zshrc" 2>/dev/null || sed -i '/aurora_theme.sh/d' "$HOME/.zshrc"
    
    # Add the new source line
    echo "source $INSTALL_DIR/aurora_theme.sh" >> "$HOME/.zshrc"
    echo -e "\033[1;32m✅ Successfully linked to .zshrc\033[0m"
else
    echo -e "\033[1;33m⚠️  Warning: .zshrc not found. Manual setup required.\033[0m"
fi

# 4. FINALIZING
echo -e "\n\033[1;35m✨ Installation Complete!\033[0m"
echo "To activate immediately, run: \033[1;33msource ~/.zshrc\033[0m"