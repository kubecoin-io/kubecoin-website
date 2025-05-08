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
echo "Compiling and installing latest Stork search from source (master branch)..."
# Clone with --recursive to fetch submodules like stork-wasm/static
git clone --recursive https://github.com/jameslittle230/stork.git stork-repo
cd stork-repo
echo "Current branch and status in stork-repo:"
git status
echo "Ensuring we are on master and up to date..."
git checkout master # Or the specific tag like v1.6.0 if preferred
git pull origin master
echo "Syncing and initializing/updating submodules recursively..."
git submodule sync --recursive
git submodule update --init --recursive

echo "DEBUG: Git submodule status AFTER update:"
git submodule status --recursive

echo "Updating ALL Stork dependencies (Rust)..."
cargo update
echo "Building Stork CLI..."
cargo build --release
cp target/release/stork $HOME/.cargo/bin/stork

echo "DEBUG: Current directory before attempting to cd into stork-wasm: $(pwd)"
echo "DEBUG: Listing contents of current directory (should be stork-repo):"
ls -la
echo "DEBUG: Checking existence of stork-wasm directory:"
if [ -d "stork-wasm" ]; then
  echo "DEBUG: stork-wasm directory exists in $(pwd)."
else
  echo "DEBUG: stork-wasm directory DOES NOT exist in $(pwd)."
  echo "DEBUG: Listing subdirectories of $(pwd) that might be relevant:"
  ls -d */ 2>/dev/null || echo "DEBUG: No subdirectories found or ls -d failed."
fi

echo "DEBUG: Enabling command tracing."
set -x # Enable command tracing to see the exact commands being run

# --- Build Stork Wasm assets (low-level) ---
echo "Building Stork Wasm assets (low-level bindings)..."
cd stork-wasm # Navigate to the wasm crate
if ! command -v wasm-pack &> /dev/null
then
    echo "wasm-pack could not be found, installing..."
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
    export PATH="$HOME/.cargo/bin:$PATH" # Ensure wasm-pack is in PATH
fi
wasm-pack build --target web --out-dir pkg

set +x # Disable command tracing
echo "DEBUG: Successfully changed to stork-wasm and ran wasm-pack. Current directory: $(pwd)"
cd .. # Back to stork-repo root
echo "DEBUG: Returned to stork-repo root. Current directory: $(pwd)"

# --- Build Stork JS Bundle (high-level API) ---
echo "Building Stork JS bundle (high-level API)..."
cd js # Navigate to stork-repo/js/
echo "Installing JS dependencies for Stork bundle..."
npm install
echo "Building Stork JS bundle with Rollup..."
npm run build # This should create dist/stork.js and dist/stork.wasm
cd .. # Back to stork-repo root

# --- Populate web-assets with bundled Stork JS and Wasm ---
echo "Creating web-assets directory and populating it with bundled Stork assets..."
rm -rf web-assets # Clean up
mkdir -p web-assets
cp js/dist/stork.js web-assets/stork.js
cp js/dist/stork.wasm web-assets/stork.wasm # Note: stork.wasm, not _bg.wasm
# Also copy CSS
cp themes/basic.css web-assets/basic.css # Assuming this is still the desired source
cp themes/dark.css web-assets/dark.css   # Assuming this is still the desired source
echo "web-assets populated with bundled Stork."

# --- Copy Stork web assets to theme ---
echo "Copying bundled Stork web assets to theme..."
THEME_ASSET_DIR="../themes/papyrus/static" # Relative path from stork-repo
mkdir -p "$THEME_ASSET_DIR/js"
mkdir -p "$THEME_ASSET_DIR/css"
cp web-assets/stork.js "$THEME_ASSET_DIR/js/stork.js"
cp web-assets/stork.wasm "$THEME_ASSET_DIR/js/stork.wasm" # Use stork.wasm
cp web-assets/basic.css "$THEME_ASSET_DIR/css/stork.css"
cp web-assets/dark.css "$THEME_ASSET_DIR/css/stork-dark.css"
echo "Bundled Stork web assets copied."

cd .. # Back to project root
rm -rf stork-repo # Clean up
echo "Stork compiled and installed. Stork version:"
stork --version
# --- End Stork Installation ---

# Upgrade pip to latest version to eliminate warnings
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies from the renamed file
echo "Installing Python dependencies..."
pip install -r dependencies.txt

# Verify Stork is in PATH for Pelican
echo "Verifying Stork availability for Pelican..."
which stork
stork --version

# Generate site with Pelican
echo "Generating site with Pelican..."
# Use publishconf.py for final build settings (like SITEURL)
pelican content -o output -s publishconf.py

# Check for Stork index file in output
echo "Listing contents of output directory to check for Stork index file (.st):"
ls -l output/
echo "Listing contents of output/theme/js/ to check for Wasm file presence and name:"
ls -Al output/theme/js/

# Success message
echo "Site build completed successfully!"