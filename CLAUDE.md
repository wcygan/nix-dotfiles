# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based dotfiles repository for cross-platform package management and environment configuration supporting macOS, Fedora, and Ubuntu. It uses Nix flakes to provide a declarative, reproducible system setup.

## Development Environment

- **Shell**: Fish shell (https://fishshell.com/docs/current/#configuration)
  - Configuration: `~/.config/fish/config.fish`
  - Functions: `~/.config/fish/functions/`
  - Completions: `~/.config/fish/completions/`
  
- **Terminal**: Ghostty (https://ghostty.org/docs/config)
  - Configuration: `~/.config/ghostty/config`
  
- **Editor**: Zed (https://zed.dev/docs/configuring-zed)
  - Settings: `~/.config/zed/settings.json`
  - Keymap: `~/.config/zed/keymap.json`

## Common Commands

### Installation & Setup
```bash
# Install Nix and packages (from dotfiles/ directory)
./install.sh

# Install packages without full setup
cd dotfiles
nix profile install . --impure
```

### Package Management
```bash
# Update flake dependencies
nix flake update

# Apply package changes after editing flake.nix
nix profile install .

# List installed packages
nix profile list

# Clean old package versions
nix-collect-garbage -d
```

### macOS Nix Cleanup
```bash
# Remove Nix build users (rm.sh script)
./rm.sh
```

## Architecture

### Directory Structure
```
.
├── dotfiles/              # Main dotfiles directory
│   ├── flake.nix         # Nix package definitions (edit to add/remove packages)
│   ├── install.sh        # Main installation script
│   ├── config/
│   │   └── shell-nix.sh  # Shell configuration for Nix
│   └── scripts/
│       └── install-nix.sh # Nix installer script
└── rm.sh                 # macOS Nix user cleanup
```

### Key Components

**flake.nix**: Declarative package list using Nix flakes. Supports multiple architectures (x86_64/aarch64 for Linux/macOS). All system packages are defined here - modify this file to add or remove tools.

**install.sh**: Orchestrates the complete setup:
1. Installs Nix if not present
2. Enables flakes experimental feature
3. Installs packages via the flake
4. Configures shell PATH for Nix
5. Sets up dotfile symlinks (currently commented out - add as needed)

### Development Workflow

When modifying packages:
1. Edit `dotfiles/flake.nix` to add/remove packages
2. Run `cd dotfiles && nix profile install .` to apply changes
3. Verify with `nix profile list`

The repository includes modern CLI tools (ripgrep, fd, bat, eza, delta, etc.) and development essentials (git, gh, docker, tmux, neovim, etc.) by default.