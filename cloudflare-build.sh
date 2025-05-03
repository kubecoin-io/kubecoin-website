#!/bin/bash
set -e

# --- Install Rust Toolchain ---
echo "Installing Rust toolchain..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
# Add cargo to the PATH for the current script execution
source "$HOME/.cargo/env"
echo "Rust installed. Cargo version:"
cargo --version
# --- End Rust Installation ---

# Upgrade pip to latest version to eliminate warnings
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Generate site with Pelican
echo "Generating site with Pelican..."
# No need to cd if the script is in the root and build command runs from root
pelican content -o output -s publishconf.py

# Success message
echo "Site build completed successfully!"
