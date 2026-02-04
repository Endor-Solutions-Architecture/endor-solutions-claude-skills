#!/bin/bash

# Endor Labs Claude Code Skill Installer
# This script installs the Endor Labs skill into your Claude Code configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="$SCRIPT_DIR/.claude"

echo "==================================="
echo "Endor Labs Claude Code Skill Setup"
echo "==================================="
echo

# Check for endorctl
if ! command -v endorctl &> /dev/null; then
    echo "Warning: endorctl not found in PATH"
    echo "Install it with one of these methods:"
    echo "  - brew install endorlabs/tap/endorctl"
    echo "  - npm install -g endorctl"
    echo "  - curl -sSL https://api.endorlabs.com/download/latest/endorctl_\$(uname -s | tr '[:upper:]' '[:lower:]')_amd64 -o endorctl"
    echo
fi

# Check for ENDOR_NAMESPACE
if [ -z "$ENDOR_NAMESPACE" ]; then
    echo "Warning: ENDOR_NAMESPACE environment variable not set"
    echo "Set it with: export ENDOR_NAMESPACE=your-namespace"
    echo
fi

# Choose installation type
echo "Where do you want to install the skill?"
echo "1) Current project (./.claude) - Team can share via git"
echo "2) User home (~/.claude) - Available in all projects"
echo "3) Custom path"
echo
read -p "Choose option [1-3]: " choice

case $choice in
    1)
        INSTALL_DIR="./.claude"
        ;;
    2)
        INSTALL_DIR="$HOME/.claude"
        ;;
    3)
        read -p "Enter custom path: " INSTALL_DIR
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Create directory if needed
mkdir -p "$INSTALL_DIR/commands"
mkdir -p "$INSTALL_DIR/rules"

# Copy files
echo "Installing to $INSTALL_DIR..."

# Copy commands
cp -r "$SKILL_SOURCE/commands/"* "$INSTALL_DIR/commands/" 2>/dev/null || true

# Copy rules
cp -r "$SKILL_SOURCE/rules/"* "$INSTALL_DIR/rules/" 2>/dev/null || true

# Merge or create settings.json
if [ -f "$INSTALL_DIR/settings.json" ]; then
    echo "Existing settings.json found. Please manually add MCP server config:"
    echo
    cat "$SKILL_SOURCE/settings.json"
    echo
else
    cp "$SKILL_SOURCE/settings.json" "$INSTALL_DIR/settings.json"
    echo "Created settings.json with MCP server configuration"
fi

# Copy CLAUDE.md if installing to project
if [ "$choice" = "1" ]; then
    if [ -f "./CLAUDE.md" ]; then
        echo "Existing CLAUDE.md found. Please manually merge content from:"
        echo "$SCRIPT_DIR/CLAUDE.md"
    else
        cp "$SCRIPT_DIR/CLAUDE.md" "./CLAUDE.md"
        echo "Created CLAUDE.md with project instructions"
    fi
fi

echo
echo "==================================="
echo "Installation complete!"
echo "==================================="
echo
echo "Available commands:"
echo "  /endor        - Main security assistant"
echo "  /endor-scan   - Quick repository scan"
echo "  /endor-check  - Check specific dependency"
echo "  /endor-findings - Show security findings"
echo "  /endor-fix    - Remediate vulnerabilities"
echo "  /endor-explain - Explain a CVE"
echo "  /endor-api    - Direct API access"
echo
echo "Next steps:"
echo "1. Ensure endorctl is installed and authenticated (endorctl init)"
echo "2. Set ENDOR_NAMESPACE environment variable"
echo "3. Restart Claude Code to load the skill"
echo
echo "Try it: /endor scan"
