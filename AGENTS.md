# AGENTS.md

## Mission
Keep tooling reproducible with Nix; keep configs portable via symlinks. Do not migrate dotfiles into Home Manager.

## Authority
You may:
- Edit `flake.nix`, `scripts/*.sh`, `config/**`, `Makefile`, `README.md`.
- Open PRs that are idempotent, reversible, and pass tests.

You must not:
- Commit secrets, machine-specific paths, or systemd/launchd tweaks outside scripts.
- Break cross-platform support (macOS, Ubuntu, Fedora).

## Decision Tree
- Need a tool? → Add to `flake.nix` → `nix profile install .`
- Need a config? → Add under `config/**` → wire in `scripts/link-config.sh`.
- Unsure? → Prefer symlinked config over baking config into derivations.

## Commands to use
- Install end-to-end: `./install.sh`
- Relink configs: `./scripts/link-config.sh [--dry-run]`
- Update tools: `make update` (or `nix flake update && nix profile upgrade '.*'`)
- Tests: `make test-pre` → `make test-local` → `make test-docker` (optional)

## Quality Bar (PR checklist)
- [ ] Cross-platform (macOS, Ubuntu, Fedora) paths verified
- [ ] Idempotent (safe to run twice)
- [ ] `make test-pre` passes
- [ ] Docs updated (README or comments)
- [ ] Rollback obvious (no destructive moves without backup)

## Troubleshooting canon
- Source daemon: `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
- Fish not seeing Nix? Use `exec fish -l` and verify `config/fish/conf.d/10-nix.fish`
- Fedora: keep SELinux enforcing; Determinate installer sets policy.
