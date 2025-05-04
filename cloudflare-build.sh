#!/bin/bash
set -e

# --- Install System Dependencies (like OpenSSL 1.1) ---
echo "Updating package list and installing libssl1.1..."
apt-get update -y
apt-get install -y libssl1.1
echo "libssl1.1 installation attempted."
# --- End System Dependencies ---

# --- Install Rust Toolchain ---
echo "Installing Rust toolchain..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
source "$HOME/.cargo/env"
echo "Rust installed. Cargo version:"
cargo --version
# --- End Rust Installation ---

# --- Install Stork Binary ---
echo "Installing Stork search binary..."
# Define Stork version - Check https://github.com/jameslittle230/stork/releases for latest tag
STORK_VERSION="v1.6.0"
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
# Download Stork binary (adjust asset name if needed for future versions)
curl -L "https://github.com/jameslittle230/stork/releases/download/${STORK_VERSION}/stork-ubuntu-20-04" -o "$INSTALL_DIR/stork"
chmod +x "$INSTALL_DIR/stork"
# Add Stork to PATH
export PATH="$INSTALL_DIR:$PATH"
echo "Stork installed. Stork version:"
# Verify Stork runs *after* installing libssl1.1
stork --version
# --- End Stork Installation ---

# Upgrade pip to latest version to eliminate warnings
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies from the renamed file
echo "Installing Python dependencies..."
pip install -r dependencies.txt

# Generate site with Pelican
echo "Generating site with Pelican..."
# Use publishconf.py for final build settings (like SITEURL)
pelican content -o output -s publishconf.py

# Success message
echo "Site build completed successfully!"