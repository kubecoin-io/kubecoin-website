#!/bin/bash
set -e

# Upgrade pip to latest version to eliminate warnings
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt

# Generate site with Pelican
cd "$(dirname "$0")"
pelican content -o output -s publishconf.py

# Success message
echo "Site build completed successfully!"