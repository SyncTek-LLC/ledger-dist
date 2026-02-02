#!/bin/bash
# CodeAtlas Ledger Install Script
# Usage: curl -fsSL https://raw.githubusercontent.com/mauricecarrier7/ledger-dist/main/install.sh | bash
#
# Or with specific version:
#   curl -fsSL .../install.sh | bash -s -- --version 0.8.2

set -e

# Defaults
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
VERSION="${VERSION:-latest}"
REPO="mauricecarrier7/ledger-dist"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}▸${NC} $1"; }
log_warn() { echo -e "${YELLOW}▸${NC} $1"; }
log_error() { echo -e "${RED}▸${NC} $1"; exit 1; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --version|-v) VERSION="$2"; shift 2 ;;
        --dir|-d) INSTALL_DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Detect platform
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin) PLATFORM="macos" ;;
    Linux) PLATFORM="linux" ;;
    *) log_error "Unsupported OS: $OS" ;;
esac

case "$ARCH" in
    arm64|aarch64) ARCH="arm64" ;;
    x86_64) ARCH="x64" ;;
    *) log_error "Unsupported architecture: $ARCH" ;;
esac

BINARY_NAME="ledger-${PLATFORM}-${ARCH}"

# Get version info
if [[ "$VERSION" == "latest" ]]; then
    log_info "Fetching latest version..."
    VERSION=$(curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/versions.json" | grep '"latest"' | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
fi

log_info "Installing ledger v${VERSION}..."

# Download URL
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${VERSION}/${BINARY_NAME}"
CHECKSUM_URL="https://github.com/${REPO}/releases/download/v${VERSION}/${BINARY_NAME}.sha256"

# Create temp directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Download binary
log_info "Downloading from ${DOWNLOAD_URL}..."
curl -fsSL -o "$TMP_DIR/ledger" "$DOWNLOAD_URL" || log_error "Download failed"

# Verify checksum
log_info "Verifying checksum..."
EXPECTED_SHA=$(curl -fsSL "$CHECKSUM_URL" | awk '{print $1}')
ACTUAL_SHA=$(shasum -a 256 "$TMP_DIR/ledger" | awk '{print $1}')

if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
    log_error "Checksum mismatch! Expected: $EXPECTED_SHA, Got: $ACTUAL_SHA"
fi
log_info "Checksum verified ✓"

# IMPORTANT: Clear macOS quarantine/provenance attributes
# This prevents the binary from hanging on execution
if [[ "$OS" == "Darwin" ]]; then
    log_info "Clearing macOS quarantine attributes..."
    xattr -cr "$TMP_DIR/ledger" 2>/dev/null || true
fi

# Make executable
chmod +x "$TMP_DIR/ledger"

# Install
log_info "Installing to ${INSTALL_DIR}/ledger..."
if [[ -w "$INSTALL_DIR" ]]; then
    mv "$TMP_DIR/ledger" "$INSTALL_DIR/ledger"
else
    log_warn "Need sudo to install to $INSTALL_DIR"
    sudo mv "$TMP_DIR/ledger" "$INSTALL_DIR/ledger"
fi

# Verify installation
if command -v ledger &> /dev/null; then
    INSTALLED_VERSION=$(ledger --version 2>/dev/null || echo "unknown")
    log_info "Successfully installed ledger v${INSTALLED_VERSION}"
else
    log_warn "Installed but 'ledger' not in PATH. Add ${INSTALL_DIR} to your PATH."
fi

echo ""
echo "Usage:"
echo "  ledger init           # Initialize in current repo"
echo "  ledger observe        # Run analysis"
echo "  ledger --help         # Show all commands"
