#!/bin/bash
set -e

# --- Install Pagefind ---
echo "Installing Pagefind..."
curl -OL https://github.com/CloudCannon/pagefind/releases/download/v1.1.0/pagefind-v1.1.0-linux-x64.tar.gz
tar -xzf pagefind-v1.1.0-linux-x64.tar.gz
mv pagefind-v1.1.0-linux-x64/pagefind $HOME/.local/bin/pagefind
rm pagefind-v1.1.0-linux-x64.tar.gz
rm -rf pagefind-v1.1.0-linux-x64
export PATH="$HOME/.local/bin:$PATH"
echo "Pagefind installed. Version:"
pagefind --version
# --- End Pagefind Installation ---

# Upgrade pip to latest version to eliminate warnings
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies from the renamed file
echo "Installing Python dependencies..."
pip install -r dependencies.txt

# Generate site with Pelican
echo "Generating site with Pelican..."
pelican content -o output -s publishconf.py

# --- Run Pagefind ---
echo "Running Pagefind to index site..."
pagefind --site output
# --- End Pagefind ---

# Success message
echo "Site build completed successfully!"