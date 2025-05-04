#!/bin/bash
set -e

# --- System Dependencies Section Removed (sudo apt-get doesn't work) ---

# --- Install Rust Toolchain ---
echo "Installing Rust toolchain..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
source "$HOME/.cargo/env"
echo "Rust installed. Cargo version:"
cargo --version
# --- End Rust Installation ---

# --- Compile and Install Latest Stork from Source ---
echo "Compiling and installing latest Stork search from source (main branch)..."
# Clone the Stork repository's main branch
git clone --depth 1 --recursive --shallow-submodules https://github.com/jameslittle230/stork.git stork-repo
cd stork-repo
# Update dependencies (specifically wasm-bindgen) before building
echo "Updating Stork dependencies..."
cargo update -p wasm-bindgen # Update wasm-bindgen and related dependencies
# Build Stork in release mode
echo "Building Stork..."
cargo build --release
# Install the compiled binary to a location in PATH
cp target/release/stork $HOME/.cargo/bin/stork # Copy directly to cargo bin dir
cd .. # Go back to the project root
rm -rf stork-repo # Clean up the cloned repo
echo "Stork compiled and installed. Stork version:"
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


