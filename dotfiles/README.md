# Dotfiles & Nix Package Management

Cross-platform dotfiles and package management using Nix flakes for Fedora, Ubuntu, and macOS.

## Quick Start

```bash
git clone <your-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Structure

```
dotfiles/
├── flake.nix           # Nix packages definition
├── install.sh          # Main installation script  
├── scripts/
│   └── install-nix.sh  # Nix installer
└── config/
    └── shell-nix.sh    # Shell configuration for Nix
```

## Managing Packages

Edit `flake.nix` to add/remove packages, then:
```bash
nix profile install .
```

## Commands

- `nix profile list` - List installed packages
- `nix flake update` - Update package versions
- `nix-collect-garbage -d` - Clean old versions