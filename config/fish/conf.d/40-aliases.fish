# config/fish/conf.d/40-aliases.fish
#
# Session-safe aliases and interactive abbreviations.
# Keep wrappers tiny; prefer functions for nontrivial logic.

# ——— Aliases -> define callable functions ———
function __maybe_alias --argument-names name target
    if type -q $target
        alias $name="$target"
    end
end

# Core CLI shorthands (only if binary exists)
__maybe_alias g git
__maybe_alias k kubectl
__maybe_alias d docker
__maybe_alias dc docker-compose
__maybe_alias ll eza

# Decorated examples using functions (more robust than raw alias)
if type -q eza
    functions -q la; or function la --wraps='eza -la' --description 'list all'
        eza -la $argv
    end
end

# ——— Interactive abbreviations ———
# Use for long flaggy commands; expands on SPACE/TAB in interactive shells.
abbr -a kctx 'kubectl config use-context'
abbr -a kp 'kubectl get pods'
abbr -a kn 'kubectl get nodes'
abbr -a gco 'git checkout'
abbr -a gs 'git status -sb'
abbr -a gl 'git log --oneline --graph --decorate --all'
abbr -a gb 'git branch'
abbr -a gd 'git diff'
abbr -a dc 'docker compose'
abbr -a l 'eza -la'
abbr -a gcl 'git clone'
abbr -a gco 'git checkout'
abbr -a d 'deno'
abbr -a dt 'deno task'

# Guard example: only add k* abbr if kubectl is present
if not type -q kubectl
    abbr -e kctx 2>/dev/null
end

# Global editor default if unset (harmless if already set elsewhere)
set -q EDITOR; or set -gx EDITOR nvim

# User-specific aliases
alias c clear
alias dev 'cd ~/Development/'
alias lg lazygit
alias lfg 'codex --dangerously-bypass-approvals-and-sandbox'
alias lfgc 'claude --model opusplan --dangerously-skip-permissions'

# Computers
alias t 'ssh wcygan@betty -t "tmux attach -t main || tmux new -s main"'
alias m1 'ssh wcygan@betty'
alias ts 'tailscale status'
alias td 'talosctl dashboard'

# Git stuff
alias gaa 'git add .'
alias gbddd 'git branch | grep -v "main" | xargs git branch -d'
alias gsw 'git switch -c'
alias gpu 'eval git push -u origin $(git rev-parse --abbrev-ref HEAD)'
alias gds 'gd --stat'
alias gca 'git commit --amend --no-edit'
alias grco 'git rebase --continue'

# General
alias z 'zed'
alias nv 'nvim'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map "xargs -n1"