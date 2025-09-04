{
  description = "System packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs allSystems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      packages = forAllSystems (
        { pkgs }:
        {
          default =
            with pkgs;
            buildEnv {
              name = "system-packages";
              paths = [
                # Version control
                git
                gh

                # Build tools
                gnumake
                cmake
                pkg-config

                # Shell and terminal
                fish
                zsh
                tmux
                starship
                
                # Coding agents
                codex
                claude-code

                # Modern CLI tools
                curl
                wget
                jq
                yq
                fzf
                ripgrep
                fd
                bat
                eza
                delta
                zoxide
                atuin

                # Development tools
                neovim
                direnv
                nix-direnv

                # Container tools
                docker-client
                docker-compose

                # Nix development
                nil
                nixd
                nixpkgs-fmt

                # System monitoring
                htop
                btop
                ncdu

                # Network tools
                nmap
                mtr
                httpie

                # File management
                tree
                unzip
                zip
                rsync
              ];
            };
        }
      );
    };
}
