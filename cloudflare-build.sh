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

# --- Install just (command runner used by Stork) ---
echo "Checking for just..."
if ! command -v just &> /dev/null
then
    echo "just could not be found, installing via cargo..."
    cargo install just
    # Ensure just is in PATH for this session if cargo install placed it in .cargo/bin
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "just is already installed."
fi
echo "just version:"
just --version

# --- Install Yarn if not present ---
echo "Checking for yarn..."
if ! command -v yarn &> /dev/null
then
    echo "yarn could not be found, installing globally via npm..."
    npm install -g yarn
else
    echo "yarn is already installed."
fi
echo "yarn version:"
yarn --version # This should now report the version set by YARN_VERSION (e.g., 1.22.19)

# --- Build Stork JS Bundle (high-level API) using just ---
echo "Building Stork JS bundle (high-level API) from $(pwd) [stork-repo root] using just..."

echo "Installing JS dependencies for Stork bundle using Yarn (from $(pwd) [stork-repo root])."
echo "Assuming YARN_VERSION environment variable is set to a Yarn 1.x version (e.g., 1.22.19) in Cloudflare Pages."

# Stork uses Yarn workspaces. Install from the root using Yarn Classic.
if [ -f "yarn.lock" ]; then # This check is now at stork-repo root
    echo "Found yarn.lock. Running 'yarn install --frozen-lockfile' with Yarn Classic."
    # --frozen-lockfile is standard for CI to ensure lockfile is not changed.
    if yarn install --frozen-lockfile; then
        echo "Yarn install (using Yarn Classic with --frozen-lockfile) successful."
    else
        echo "Yarn install (using Yarn Classic with --frozen-lockfile) FAILED."
        echo "This might happen if yarn.lock is somehow incompatible even with Yarn Classic."
        echo "Dumping yarn.lock (first 50 lines) and package.json for debugging."
        echo "--- package.json ---"
        cat package.json || echo "Failed to cat package.json"
        echo "--- yarn.lock (first 50 lines) ---"
        head -n 50 yarn.lock || echo "Failed to cat yarn.lock"
        exit 1 # Fail the build
    fi
else
    # This case means the original stork-repo/yarn.lock was missing.
    # This is unlikely if the submodule was cloned correctly.
    echo "WARNING: yarn.lock not found in $(pwd) [stork-repo root]."
    echo "Attempting 'yarn install' to create lockfile (using Yarn Classic from YARN_VERSION env var)..."
    if yarn install; then
        echo "Yarn install (lockfile creation with Yarn Classic) successful."
    else
        echo "Yarn install (lockfile creation with Yarn Classic) FAILED."
        exit 1 # Fail the build
    fi
fi

echo "Running just build-js to bundle Stork Wasm and JS..."
just build-js # This will run yarn install and webpack

echo "Listing contents of stork-repo root after just build-js:"
ls -la
echo "Listing contents of stork-repo/dist/ after just build-js (if it exists):"
ls -la dist/
echo "Listing contents of stork-repo/js/dist/ after just build-js (if it exists):"
ls -la js/dist/
echo "Finding stork.js and stork.wasm in stork-repo..."
find . -name "stork.js" -ls
find . -name "stork.wasm" -ls

# --- Populate web-assets with bundled Stork JS and Wasm ---
echo "Creating web-assets directory and populating it with bundled Stork assets..."
rm -rf web-assets # Clean up
mkdir -p web-assets
cp dist/stork.js web-assets/stork.js # Corrected path
cp dist/stork.wasm web-assets/stork.wasm # Corrected path
# Also copy CSS
cp themes/basic.css web-assets/basic.css # This path is relative to stork-repo root
cp themes/dark.css web-assets/dark.css   # This path is relative to stork-repo root
echo "web-assets populated with bundled Stork."

# Copy Stork web assets to theme
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