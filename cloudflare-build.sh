#!/bin/bash
set -e

# --- Pagefind will be installed via dependencies.txt ---
echo "Pagefind will be installed via dependencies.txt"
echo "Checking Pagefind version after dependencies installation..."
# --- End Pagefind Installation ---

# --- Install Node.js dependencies for the theme (Tailwind CSS) ---
echo "Installing Node.js dependencies for the Papyrus theme..."
if [ -f "themes/papyrus/package.json" ]; then
  cd themes/papyrus
  # Use npm ci for cleaner installs if package-lock.json exists and is reliable
  if [ -f "package-lock.json" ]; then
    npm ci
  else
    npm install
  fi
  cd ../.. # Navigate back to the project root
  echo "Node.js dependencies for Papyrus theme installed."
else
  echo "Warning: themes/papyrus/package.json not found. Skipping npm install for theme."
fi
# --- End Node.js dependencies installation ---

# Upgrade pip to latest version to eliminate warnings
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies from the renamed file
echo "Installing Python dependencies..."
pip install -r dependencies.txt

python3 -m pagefind --version # Moved version check to after install

# Generate site with Pelican
echo "Generating site with Pelican..."
pelican content -o output -s publishconf.py

# --- Run Pagefind ---
echo "Running Pagefind to index site..."
python3 -m pagefind --site output
# --- End Pagefind ---

# Success message
echo "Site build completed successfully!"