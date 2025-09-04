#!/usr/bin/env bash
set -euo pipefail

echo "🐳 Docker-based Ephemeral Test Environment"
echo "=========================================="
echo ""

# Check if Docker is available
if ! command -v docker &>/dev/null; then
    echo "❌ Docker not found. Install Docker to use this test."
    echo "   Alternatively, use ./test-ephemeral.sh for local testing"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &>/dev/null; then
    echo "❌ Docker daemon not running. Please start Docker."
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 Building test container with Nix + Fish..."
echo ""

# Create Dockerfile for test environment
cat > "$REPO_ROOT/Dockerfile.test" << 'EODOCK'
FROM nixos/nix:latest

# Install fish and other tools in container
RUN nix-channel --update && \
    nix-env -iA nixpkgs.fish nixpkgs.direnv nixpkgs.starship nixpkgs.bash

# Create test user with home directory
RUN mkdir -p /home/testuser && \
    echo "testuser:x:1000:1000:Test User:/home/testuser:/run/current-system/sw/bin/bash" >> /etc/passwd && \
    echo "testuser:x:1000:" >> /etc/group && \
    chown -R 1000:1000 /home/testuser

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Copy our config files and test script
COPY --chown=testuser:testuser config /tmp/test-config
COPY --chown=testuser:testuser docker-test-commands.fish /home/testuser/run-tests.fish

# Setup .config directory and link fish config
RUN mkdir -p /home/testuser/.config && \
    ln -s /tmp/test-config/fish /home/testuser/.config/fish && \
    ln -s /tmp/test-config/shell-nix.sh /home/testuser/.config/shell-nix.sh

# Set up nix profile directory
RUN mkdir -p /home/testuser/.nix-profile/bin

# Make test script executable
RUN chmod +x /home/testuser/run-tests.fish

# Default to fish shell
CMD ["/nix/var/nix/profiles/default/bin/fish"]
EODOCK

# Build the container
echo "Building container..."
docker build -f "$REPO_ROOT/Dockerfile.test" -t fish-test:latest "$REPO_ROOT" || {
    echo "❌ Failed to build test container"
    rm -f "$REPO_ROOT/Dockerfile.test"
    exit 1
}

# Clean up Dockerfile
rm -f "$REPO_ROOT/Dockerfile.test"

echo ""
echo "🚀 Starting ephemeral test container..."
echo "---"
echo "This is a completely isolated environment."
echo "Your system configuration will NOT be affected."
echo ""
echo "📝 Quick Test Commands:"
echo "  → ./run-tests.fish         # Run automated test suite"
echo ""
echo "🔍 Manual Test Commands:"
echo "  → echo \$NIX_CONFIG         # Check Nix config"
echo "  → functions | grep nix     # List custom functions"
echo "  → nix-try --help           # Test custom function"
echo "  → abbr --show              # Show abbreviations"
echo "  → type -a nix-install      # Check function location"
echo "  → set | grep NIX           # Show NIX variables"
echo "  → exit                     # Leave container"
echo ""
echo "=========================================="

# Run interactive container
docker run -it --rm \
    --name fish-test-env \
    -e "TERM=$TERM" \
    fish-test:latest

echo ""
echo "✨ Test container destroyed. No changes were made to your system."
