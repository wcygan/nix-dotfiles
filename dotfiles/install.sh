#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
OS=$(uname -s)

echo "🚀 Starting dotfiles installation..."
echo "📁 Dotfiles directory: $DOTFILES_DIR"

# Create necessary directories
echo "📂 Creating config directories..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$HOME/.local/bin"

# Step 1: Install Nix if not present
if ! command -v nix &> /dev/null; then
    echo "📦 Nix not found. Installing Nix..."
    "$DOTFILES_DIR/scripts/install-nix.sh"

    # Source Nix environment
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
else
    echo "✅ Nix is already installed"
fi

# Step 2: Enable flakes (experimental feature)
echo "🔧 Configuring Nix..."
mkdir -p "$HOME/.config/nix"
cat > "$HOME/.config/nix/nix.conf" << 'EOF'
experimental-features = nix-command flakes
EOF

# Step 3: Install packages via Nix flake
echo "📦 Installing packages via Nix flake..."
cd "$DOTFILES_DIR"
nix profile install . --impure

# Step 4: Setup shell configuration
echo "🐚 Setting up shell configuration..."

# Detect shell - prefer environment variable if set by direnv
if [ -n "$DOTFILES_SHELL_PREFERENCE" ]; then
    SHELL_NAME="$DOTFILES_SHELL_PREFERENCE"
    echo "📌 Using preferred shell from environment: $SHELL_NAME"
else
    SHELL_NAME=$(basename "$SHELL")
fi
SHELL_RC=""

case "$SHELL_NAME" in
    bash)
        SHELL_RC="$HOME/.bashrc"
        ;;
    zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    fish)
        SHELL_RC="$HOME/.config/fish/config.fish"
        mkdir -p "$HOME/.config/fish"
        # Check if Fish is actually installed
        if ! command -v fish &> /dev/null; then
            echo "⚠️  Fish shell requested but not found. Installing via Nix..."
            nix profile install nixpkgs#fish
        fi
        ;;
    *)
        echo "⚠️  Unknown shell: $SHELL_NAME. Please manually add Nix to your PATH."
        ;;
esac

if [ -n "$SHELL_RC" ]; then
    # Add Nix to PATH if not already present
    NIX_PROFILE_PATH='$HOME/.nix-profile/bin'

    if [ "$SHELL_NAME" = "fish" ]; then
        # Fish shell uses different syntax
        if ! grep -q "$NIX_PROFILE_PATH" "$SHELL_RC" 2>/dev/null; then
            echo "" >> "$SHELL_RC"
            echo "# Nix profile" >> "$SHELL_RC"
            echo "fish_add_path $NIX_PROFILE_PATH" >> "$SHELL_RC"
            echo "✅ Added Nix profile to $SHELL_RC"
        else
            echo "✅ Nix profile already in $SHELL_RC"
        fi
    else
        # Bash/Zsh use export
        NIX_PATH_EXPORT="export PATH=\"$NIX_PROFILE_PATH:\$PATH\""
        if ! grep -q "$NIX_PROFILE_PATH" "$SHELL_RC" 2>/dev/null; then
            echo "" >> "$SHELL_RC"
            echo "# Nix profile" >> "$SHELL_RC"
            echo "$NIX_PATH_EXPORT" >> "$SHELL_RC"
            echo "✅ Added Nix profile to $SHELL_RC"
        else
            echo "✅ Nix profile already in $SHELL_RC"
        fi
    fi
fi

# Step 5: Link dotfiles
echo "🔗 Linking configuration files..."

# Create symlinks for config files (add your dotfiles here)
link_file() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "  ⚠️  Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi

    if [ ! -e "$target" ]; then
        ln -sf "$source" "$target"
        echo "  ✅ Linked $source → $target"
    else
        echo "  ℹ️  $target already exists"
    fi
}

# Example dotfile links (uncomment and modify as needed)
# link_file "$DOTFILES_DIR/config/nvim" "$CONFIG_DIR/nvim"
# link_file "$DOTFILES_DIR/config/tmux.conf" "$HOME/.tmux.conf"
# link_file "$DOTFILES_DIR/config/gitconfig" "$HOME/.gitconfig"
# link_file "$DOTFILES_DIR/config/zshrc" "$HOME/.zshrc"

echo ""
echo "✨ Dotfiles installation complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Restart your shell or run: source $SHELL_RC"
echo "  2. Run 'nix profile list' to see installed packages"
echo "  3. Update packages with: nix flake update && nix profile upgrade"
echo ""
echo "🔧 Managing packages:"
echo "  - Edit flake.nix to add/remove packages"
echo "  - Run 'nix profile install .' to apply changes"
echo "  - Run 'nix-collect-garbage -d' to clean up old versions"
