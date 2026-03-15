#!/bin/bash

# --- AURORA-SHELL UNIX INSTALLER ---
INSTALL_DIR="$HOME/.aurora-shell"
BIN_DIR="/usr/local/bin"

echo "🌈 Starting Aurora-Shell installation..."

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Move the theme file to the config directory
# The CI/CD puts the theme in the same folder as this script
if [ -f "./aurora_theme.sh" ]; then
    cp "./aurora_theme.sh" "$INSTALL_DIR/aurora_theme.sh"
    chmod +x "$INSTALL_DIR/aurora_theme.sh"
    echo "✅ Theme installed to $INSTALL_DIR"
else
    echo "❌ Error: aurora_theme.sh not found in current directory."
    exit 1
fi

echo "🚀 Installation complete! You can now source $INSTALL_DIR/aurora_theme.sh in your zshrc/bashrc."