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
# Update ALL dependencies before building
echo "Updating ALL Stork dependencies..."
cargo update # <-- Changed this line
# Build Stork in release mode
echo "Building Stork..."
cargo build --release
# Install the compiled binary to a location in PATH
cp target/release/stork $HOME/.cargo/bin/stork # Copy directly to cargo bin dir

# --- Debug Stork asset paths ---
echo "--- Debugging Stork asset paths ---"
echo "Current directory: $(pwd)" # Should be /opt/buildhome/repo/stork-repo

echo "Checking for stork-cli directory in $(pwd):"
if [ -d "stork-cli" ]; then
    echo "stork-cli directory EXISTS."
    echo "Listing contents of stork-cli/:"
    ls -A stork-cli/
    
    echo "Checking for stork-cli/web-assets directory in $(pwd)/stork-cli/:"
    if [ -d "stork-cli/web-assets" ]; then
        echo "stork-cli/web-assets directory EXISTS."
        echo "Listing contents of stork-cli/web-assets/:"
        ls -A stork-cli/web-assets/
        
        echo "Full path check for stork.js: $(pwd)/stork-cli/web-assets/stork.js"
        if [ -f "stork-cli/web-assets/stork.js" ]; then
            echo "stork.js FOUND in stork-cli/web-assets/"
        else
            echo "stork.js NOT FOUND in stork-cli/web-assets/"
        fi
        
        echo "Full path check for basic.css: $(pwd)/stork-cli/web-assets/basic.css"
        if [ -f "stork-cli/web-assets/basic.css" ]; then
            echo "basic.css FOUND in stork-cli/web-assets/"
        else
            echo "basic.css NOT FOUND in stork-cli/web-assets/"
        fi

        echo "Full path check for dark.css: $(pwd)/stork-cli/web-assets/dark.css"
        if [ -f "stork-cli/web-assets/dark.css" ]; then
            echo "dark.css FOUND in stork-cli/web-assets/"
        else
            echo "dark.css NOT FOUND in stork-cli/web-assets/"
        fi
    else
        echo "stork-cli/web-assets directory DOES NOT EXIST in $(pwd)/stork-cli/."
    fi
else
    echo "stork-cli directory DOES NOT EXIST in $(pwd)."
fi
echo "--- End Debugging Stork asset paths ---"

# --- Copy Stork web assets to theme ---
echo "Copying Stork web assets to theme..."
THEME_ASSET_DIR="../themes/papyrus/static" # Relative path from stork-repo back to project then to theme
mkdir -p "$THEME_ASSET_DIR/js"
mkdir -p "$THEME_ASSET_DIR/css"
# Assuming stork.js, basic.css, and dark.css are in the root of the stork-repo or standard subdirs
# Adjust these paths if Stork project structure is different for web assets
cp stork-cli/web-assets/stork.js "$THEME_ASSET_DIR/js/stork.js"
cp stork-cli/web-assets/basic.css "$THEME_ASSET_DIR/css/stork.css" # Rename basic.css to stork.css
cp stork-cli/web-assets/dark.css "$THEME_ASSET_DIR/css/stork-dark.css" # Rename dark.css to stork-dark.css
echo "Stork web assets copied."
# --- End Copy Stork web assets ---

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