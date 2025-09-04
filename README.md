# Nix + Dotfiles (Cross‑Platform)

Reproducible tooling via **Nix (flakes)**, portable configs via **symlinks**.

* **Platforms**: macOS (Intel/Apple Silicon), Ubuntu, Fedora
* **Installer**: [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)
* **Shells supported**: fish (native), bash/zsh (via `config/shell-nix.sh`)

---

## Prerequisites

* macOS 12+ or a recent Ubuntu/Fedora
* `curl` and a POSIX shell available (default on all three)
* For Ubuntu/Fedora: user must be in the `sudoers` group

> The Determinate installer handles `/nix` mount setup, users/groups, and SELinux policy (Fedora) automatically.

---

## Quick Start

### 1) Install Nix (all platforms)

```bash
# Determinate Systems – single, cross‑platform command
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**After install**: open a **new shell** or source the daemon profile if present:

```bash
# multi‑user daemon (preferred on macOS + most Linux)
[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] \
  && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Verify:

```bash
nix --version
```

### 2) Clone and bootstrap

```bash
# Clone this repo
REPO_DIR="$HOME/nix-dotfiles"   # change if you want
git clone <YOUR-REPO-URL> "$REPO_DIR"
cd "$REPO_DIR"

# One‑shot: install Nix (if missing), install packages, link configs
./install.sh
```

What `./install.sh` does:

1. Runs `scripts/install-nix.sh` (idempotent) using Determinate installer
2. Installs packages from `flake.nix` via `scripts/install-packages.sh`
3. Symlinks configs via `scripts/link-config.sh`

### 3) Shell integration

**fish (recommended)**

* Config is symlinked into `~/.config/fish` (see `config/fish/*`).
* Open a new **login** fish, or run:

```fish
exec fish -l
```

**bash/zsh**

Append once to `~/.bashrc` or `~/.zshrc`:

```bash
echo 'source ~/.config/shell-nix.sh' >> ~/.bashrc   # or ~/.zshrc
```

Open a new terminal.

---

## OS‑Specific Notes

### macOS

* Multi‑user install is default; the daemon profile is at
  `/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`.
* If you use Apple Silicon, all packages in `flake.nix` target `aarch64-darwin` automatically.

### Ubuntu

* Installer configures `/nix` mount and system users.
* If you use WSL, make sure you start a **new login shell** after install.

### Fedora

* Installer sets an SELinux policy for Nix; keep SELinux **enforcing**.
* If you manually disable SELinux, Nix store operations may fail.

---

## Daily Use

```bash
# List installed packages
nix profile list

# Update flake inputs + upgrade to latest versions
make update        # or:
# nix flake update && nix profile upgrade '.*'

# Start fish (after linking)
make fish

# Enter dev shell (if you add one later)
nix develop
```

Symlink management:

```bash
# Re-link configs (safe: backs up non‑symlink targets)
./scripts/link-config.sh

# Preview links without changing your system
./scripts/link-config.sh --dry-run
```

---

## Test Suite (Optional but handy)

```bash
# Pre‑flight checks
make test-pre

# Local ephemeral test (temp HOME, no system changes)
make test-local

# Docker isolated test (requires Docker)
make test-docker
```

Inside Docker, run `./run-tests.fish` to exercise the fish config.

---

## Project Layout

```
config/
  fish/                 # fish config (conf.d, functions, config.fish)
  shell-nix.sh          # bash/zsh helper to load Nix env
scripts/
  install-nix.sh        # Determinate Nix installer wrapper
  install-packages.sh   # install packages from flake.nix
  link-config.sh        # symlink configs into ~/.config and $HOME
flake.nix               # package set (cross‑platform)
install.sh              # orchestrated installer
Makefile                # common tasks (install, test, update, etc.)
```

---

## Troubleshooting

**“`xdg-open: unexpected argument ... nix-daemon.sh`”**

* You likely tried to *execute* the profile script with a desktop opener.
* Correct action is to **source** it in your shell:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

**Fish doesn’t see Nix packages**

* Open a **login** fish: `exec fish -l`
* Ensure `config/fish/conf.d/10-nix.fish` exists (it adds Nix paths + env)

**Fedora SELinux denials**

* Keep SELinux **enforcing**; the installer ships a policy. If you changed SELinux mode, restore it and reinstall the policy by re‑running the installer.

**macOS: cannot write `/nix`**

* Use the Determinate installer (already in our scripts) — it creates a dedicated APFS volume and mount.

---

## Uninstall / Clean Up (Selective)

* Remove symlinks only:

```bash
make uninstall
```

* Reclaim space from old package generations:

```bash
nix-collect-garbage -d
```

> Full Nix removal differs by OS; use the official uninstaller from Determinate/NixOS docs if you truly want to remove `/nix`.

---

## Contributing

* Add tools in `flake.nix`; keep user configs under `config/`
* Keep PRs small; run `make test-pre` before submitting

---

## License

Choose a license and add it to `LICENSE`.
