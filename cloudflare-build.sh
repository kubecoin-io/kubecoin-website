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
# Simplify clone, ensure it's not shallow for the main repo
git clone https://github.com/jameslittle230/stork.git stork-repo # Removed --recursive, --shallow-submodules
cd stork-repo
echo "Current branch and status in stork-repo:"
git status
echo "Ensuring we are on main and up to date..."
git checkout main
git pull origin main # Ensure it's the latest from main

# Update ALL dependencies before building
echo "Updating ALL Stork dependencies..."
cargo update
# Build Stork in release mode
echo "Building Stork..."
cargo build --release
# Install the compiled binary to a location in PATH
cp target/release/stork $HOME/.cargo/bin/stork # Copy directly to cargo bin dir

echo "Installing wasm-pack..."
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
export PATH="$HOME/.cargo/bin:$PATH" # Ensure wasm-pack is in PATH if installed to .cargo/bin by script

echo "Building Stork Wasm assets..."
cd stork-wasm

echo "Current directory: $(pwd)"
echo "Listing contents of stork-wasm (BEFORE wasm-pack build):"
ls -Al # Use -Al for more details, including permissions and if 'static' is a link

# Debug: Check if Makefile exists and print its contents
if [ -f "Makefile" ]; then
    echo "Makefile exists in stork-wasm. Contents:"
    cat Makefile
else
    echo "Makefile NOT FOUND in stork-wasm."
fi

echo "Attempting to build Wasm assets directly with wasm-pack..."
wasm-pack build --target web --out-dir pkg

cd .. # Back to stork-repo root

echo "Creating web-assets directory and populating it..."
rm -rf web-assets # Clean up if it exists from a partial previous run
mkdir -p web-assets

# Debugging: List contents of pkg directory to confirm generated file names
echo "Current directory before copying assets: $(pwd)"
echo "Listing contents of stork-wasm/ (should contain pkg/ and CSS files):"
ls -A stork-wasm/
echo "Listing contents of stork-wasm/pkg/:"
ls -A stork-wasm/pkg/

# Copy and rename assets from stork-wasm/pkg and stork-wasm/
# based on Stork's own Makefile logic (wasm crate name is stork-wasm)
cp stork-wasm/pkg/stork_wasm.js web-assets/stork.js
cp stork-wasm/pkg/stork_wasm_bg.wasm web-assets/stork.wasm
# CSS files are in stork-wasm/static/css/
cp stork-wasm/static/css/stork.css web-assets/basic.css
cp stork-wasm/static/css/dark.css web-assets/dark.css

echo "web-assets populated."

# --- Debug Stork asset paths ---
echo "--- Debugging Stork asset paths ---"
echo "Current directory: $(pwd)" # Should be /opt/buildhome/repo/stork-repo

echo "Checking for web-assets directory in $(pwd):"
if [ -d "web-assets" ]; then
    echo "web-assets directory EXISTS."
    echo "Listing contents of web-assets/:"
    ls -A web-assets/
    
    echo "Full path check for stork.js: $(pwd)/web-assets/stork.js"
    if [ -f "web-assets/stork.js" ]; then
        echo "stork.js FOUND in web-assets/"
    else
        echo "stork.js NOT FOUND in web-assets/"
    fi
    
    echo "Full path check for basic.css: $(pwd)/web-assets/basic.css"
    if [ -f "web-assets/basic.css" ]; then
        echo "basic.css FOUND in web-assets/"
    else
        echo "basic.css NOT FOUND in web-assets/"
    fi

    echo "Full path check for dark.css: $(pwd)/web-assets/dark.css"
    if [ -f "web-assets/dark.css" ]; then
        echo "dark.css FOUND in web-assets/"
    else
        echo "dark.css NOT FOUND in web-assets/"
    fi
else
    echo "web-assets directory DOES NOT EXIST in $(pwd)."
fi
echo "--- End Debugging Stork asset paths ---"

# --- Copy Stork web assets to theme ---
echo "Copying Stork web assets to theme..."
THEME_ASSET_DIR="../themes/papyrus/static" # Relative path from stork-repo back to project then to theme
mkdir -p "$THEME_ASSET_DIR/js"
mkdir -p "$THEME_ASSET_DIR/css"
# Adjust these paths if Stork project structure is different for web assets
cp web-assets/stork.js "$THEME_ASSET_DIR/js/stork.js"
cp web-assets/basic.css "$THEME_ASSET_DIR/css/stork.css" # Rename basic.css to stork.css
cp web-assets/dark.css "$THEME_ASSET_DIR/css/stork-dark.css" # Rename dark.css to stork-dark.css
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