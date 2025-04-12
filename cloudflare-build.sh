#!/bin/bash
set -e

# Install dependencies
pip install -r requirements.txt

# Generate site with Pelican
cd "$(dirname "$0")"
pelican content -o output -s publishconf.py

# Success message
echo "Site build completed successfully!"