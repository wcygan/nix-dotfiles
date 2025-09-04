# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based dotfiles repository for cross-platform package management and environment configuration supporting macOS, Fedora, and Ubuntu. It uses Nix flakes to provide a declarative, reproducible system setup.

## Nix Core Concepts

### Functional Package Management
Nix is a purely functional package manager that treats packages as immutable values built by functions. Key principles:
- **Immutability**: Packages in `/nix/store` cannot be modified after creation
- **Reproducibility**: Same inputs always produce identical outputs
- **Isolation**: Multiple package versions coexist without conflicts
- **Atomicity**: Upgrades and rollbacks are atomic operations

### The Nix Store
- **Location**: `/nix/store` contains all packages and dependencies
- **Naming**: Packages use cryptographic hashes (e.g., `/nix/store/hash-name-version`)
- **References**: Store objects track dependencies precisely
- **Garbage Collection**: Unused packages can be safely removed

### Derivations
Derivations are build recipes that specify:
- **Inputs**: Dependencies and source files
- **Builder**: Executable that performs the build
- **Environment**: Variables for the build process
- **Outputs**: One or more resulting store paths

### Profiles & Generations
- **Profiles**: Mutable references to immutable store paths
- **Generations**: Historical versions of a profile
- **Rollback**: Switch between generations instantly
- **User Profiles**: Each user has isolated package environments

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

# Show package dependencies
nix-store --query --references /nix/store/path

# Check package closure size
nix path-info -Sh /nix/store/path
```

### Profile Management
```bash
# List profile generations
nix profile history

# Rollback to previous generation
nix profile rollback

# Switch to specific generation
nix profile rollback --to N

# Diff between generations
nix profile diff-closures
```

### Flake Commands
```bash
# Show flake metadata
nix flake show

# Check flake health
nix flake check

# Update specific input
nix flake lock --update-input nixpkgs

# Build without installing
nix build .#packageName

# Develop shell environment
nix develop

# Run command in package environment
nix run nixpkgs#package -- args
```

### Store Management
```bash
# Verify store integrity
nix-store --verify --check-contents

# Optimize store (hardlink duplicates)
nix-store --optimise

# Query package requisites
nix-store --query --requisites /nix/store/path

# Find referrers of a package
nix-store --query --referrers /nix/store/path
```

### Troubleshooting
```bash
# Show build log
nix log /nix/store/path

# Debug evaluation
nix eval --show-trace expression

# Check why package is retained
nix-store --query --roots /nix/store/path

# Force rebuild ignoring cache
nix build --rebuild

# Show derivation details
nix show-derivation /nix/store/path.drv
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

## Nix Language Basics

### Data Types
```nix
# Primitives
42                  # Integer
3.14                # Float  
true                # Boolean
"hello"             # String
null                # Null

# Collections
[ 1 2 3 ]           # List
{ x = 1; y = 2; }   # Attribute set
```

### Functions & Expressions
```nix
# Function definition
add = x: y: x + y

# Let expressions
let
  x = 5;
  y = 10;
in x + y

# With expressions
with pkgs; [ git vim ]

# Conditionals
if condition then value1 else value2
```

### Flake Structure
```nix
{
  description = "Package description";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = derivation;
    devShells.x86_64-linux.default = shell;
  };
}
```

## Best Practices

### Flake Development
- **Pin inputs**: Use specific commits/tags for reproducibility
- **Lock files**: Commit `flake.lock` for consistent dependencies
- **Pure evaluation**: Avoid impure operations when possible
- **Modular design**: Split complex configurations into modules

### Performance Optimization
- **Binary caches**: Configure substituters for faster builds
- **Store optimization**: Run `nix-store --optimise` periodically
- **Garbage collection**: Use `nix-collect-garbage -d` regularly
- **Minimal closures**: Reduce dependencies for smaller packages

### Troubleshooting Tips
- **Build failures**: Check logs with `nix log`
- **Evaluation errors**: Use `--show-trace` for stack traces
- **Store corruption**: Run `nix-store --verify --check-contents`
- **Space issues**: Clean with `nix-collect-garbage -d`
- **Permission problems**: Ensure proper daemon/store permissions

### Security Considerations
- **Sandboxing**: Enable build sandboxing for isolation
- **Trusted users**: Limit who can modify the store
- **Substituter trust**: Verify binary cache signatures
- **Source verification**: Use hash-checked sources

## Advanced Topics

### Content-Addressed Derivations
- Experimental feature for improved caching
- Store paths based on output content, not inputs
- Enable with `experimental-features = ca-derivations`

### Remote Builds
- Distribute builds across multiple machines
- Configure builders in `/etc/nix/machines`
- Useful for cross-compilation or resource-intensive builds

### Overlays & Overrides
```nix
# Overlay example
overlay = self: super: {
  package = super.package.override { option = value; };
};
```

### Development Shells
```nix
# Shell with specific tools
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [ gcc make python3 ];
  shellHook = ''
    echo "Development environment loaded"
  '';
};
```