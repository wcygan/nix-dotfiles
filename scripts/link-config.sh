#!/usr/bin/env bash
set -euo pipefail

# Check for dry-run mode
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]]; then
    DRY_RUN=true
    echo "🔍 DRY RUN MODE - No changes will be made"
    echo ""
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG_SRC="$REPO_ROOT/config"
CFG_DST="$HOME/.config"

mkdir -p "$CFG_DST"

link() {
  local src="$1" dst="$2"

  if $DRY_RUN; then
    echo "[DRY] Would link: $dst → $src"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
      echo "      (would backup existing $dst)"
    elif [ -L "$dst" ]; then
      echo "      (would replace existing symlink)"
    fi
  else
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
      mv "$dst" "$dst.backup.$(date +%s)"
    fi
    ln -snf "$src" "$dst"
    echo "→ $dst ↦ $src"
  fi
}

# examples you can grow over time:
# link "$CFG_SRC/nvim" "$CFG_DST/nvim"
# link "$CFG_SRC/tmux.conf" "$HOME/.tmux.conf"
# link "$CFG_SRC/gitconfig" "$HOME/.gitconfig"

# keep your Nix shell helpers:
link "$CFG_SRC/shell-nix.sh" "$CFG_DST/shell-nix.sh"

# fish config (directory link keeps the whole tree under version control)
link "$CFG_SRC/fish" "$HOME/.config/fish"
