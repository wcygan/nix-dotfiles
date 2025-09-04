{
  description = "System packages for multi-platform development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Support for Linux (x86_64, aarch64) and macOS (Intel, Apple Silicon)
      allSystems = [
        "x86_64-linux"    # Intel/AMD Linux (Ubuntu, Fedora)
        "aarch64-linux"   # ARM64 Linux
        "x86_64-darwin"   # Intel macOS
        "aarch64-darwin"  # Apple Silicon macOS
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = nixpkgs.legacyPackages.${system};
      });
    in
    {
      packages = forAllSystems ({ pkgs }: {
        default = with pkgs; buildEnv {
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
            zsh
            tmux
            starship

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

            # Language-specific tools (optional, uncomment as needed)
            # nodejs_20
            # deno
            # go
            # rustup
            # python3

            # Nix development
            nil  # Nix language server

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
      });
    };
}
