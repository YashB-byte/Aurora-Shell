#!/bin/bash
# --- AURORA-SHELL BRIDGE INSTALLER ---
INSTALL_DIR="$HOME/.aurora-shell"

echo "🌈 Preparing Aurora-Shell for current user..."
mkdir -p "$INSTALL_DIR"

if [ -f "./aurora_theme.sh" ]; then
    cp "./aurora_theme.sh" "$INSTALL_DIR/aurora_theme.sh"
    chmod +x "$INSTALL_DIR/aurora_theme.sh"
    echo "✅ Theme file placed in $INSTALL_DIR"
else
    echo "⚠️  Note: aurora_theme.sh not found locally, continuing to remote install..."
fi

# --- THE REMOTE CHAIN ---
echo "🚀 Triggering main installation script from GitHub..."
bash <(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.sh)

echo "✨ Done! Add 'source ~/.aurora-shell/aurora_theme.sh' to your .zshrc"