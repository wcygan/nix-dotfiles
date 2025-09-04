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
abbr -a gco 'git checkout'
abbr -a gst 'git status -sb'
abbr -a glg 'git log --oneline --graph --decorate --all'
abbr -a kctx 'kubectl config use-context'

# Guard example: only add k* abbr if kubectl is present
if not type -q kubectl
    abbr -e kctx 2>/dev/null
end

# Global editor default if unset (harmless if already set elsewhere)
set -q EDITOR; or set -gx EDITOR nvim
