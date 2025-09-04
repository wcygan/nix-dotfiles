# CLAUDE.md

This file provides guidance for AI assistants when working with this repository.

## Repository Purpose

This repository provides a **hybrid developer setup**:

- **Nix (flakes)**: Used strictly for cross-platform **package management** (Linux/macOS).
- **Dotfiles**: Application and shell configuration files are stored under `/config` and symlinked into `~/.config` or other expected locations.

The goal is to keep **Nix declarative for tooling** while leaving **dotfiles conventional and portable**.

---

## Core Concepts

### Nix Package Management
- Nix is used to install and manage system-level packages via the root `flake.nix`.
- It provides reproducible environments across Linux and macOS.
- We do **not** use Nix to manage dotfiles (no Home Manager). Instead, dotfiles are symlinked.

**Key commands:**
```bash
# Install packages defined in flake.nix
nix profile install . --impure

# Update flake inputs
nix flake update

# Apply changes after editing flake.nix
nix profile install .

# Clean old package versions
nix-collect-garbage -d
````

### Dotfiles via Symlinks

* All user configuration lives in `/config`.
* `scripts/link-config.sh` creates symlinks into `~/.config` or `$HOME`.
* Each config item (e.g., `fish/`, `nvim/`, `gitconfig`) can be added incrementally.

**Example:**

```bash
# Link configs
./scripts/link-config.sh

# Fish config is then available at ~/.config/fish
# Nix helpers are available at ~/.config/shell-nix.sh (bash/zsh) or ~/.config/fish/conf.d/* (fish)
```

---

## Directory Structure

```
.
├── config/                # Dotfiles (symlinked into ~/.config or $HOME)
│   ├── fish/              # Native fish config (conf.d, functions, config.fish)
│   └── shell-nix.sh       # Bash/zsh Nix environment glue
├── scripts/               # Installers and linkers
│   ├── install-nix.sh     # Installs Nix
│   ├── install-packages.sh# Installs packages from flake.nix
│   └── link-config.sh     # Creates symlinks for dotfiles
├── flake.nix              # Declarative package list
├── flake.lock             # Locked Nix inputs
├── install.sh             # Orchestrates install → packages → symlinks
└── .envrc                 # direnv integration with flake
```

---

## Development Workflow

1. **Bootstrap**

   ```bash
   ./install.sh
   direnv allow
   ```

2. **Manage Packages**

   * Edit `flake.nix` to add/remove tools.
   * Run `nix profile install .` to apply changes.

3. **Manage Dotfiles**

   * Add/edit configs in `/config`.
   * Update `scripts/link-config.sh` with new symlinks.
   * Run `./scripts/link-config.sh`.

---

## Best Practices

* Keep **tools** in `flake.nix`, keep **configs** in `/config`.
* Don’t mix config into Nix derivations (avoids lock-in).
* Run `nix-collect-garbage -d` periodically to reclaim space.
* Use `fish_add_path` and conf.d snippets for fish shell integration.

---

## Quick Reference

### Nix

* `nix profile list` → list installed packages
* `nix flake show` → show flake outputs
* `nix develop` → open a dev shell from flake
* `nix run nixpkgs#<pkg>` → run a package without installing

### Dotfiles

* `./scripts/link-config.sh` → re-link configs
* Backups are created automatically if non-symlinked files exist

---

This setup provides:

* **Reproducible tooling** with Nix.
* **Portable dotfiles** with symlinks.
* **Clear separation** of responsibilities.
