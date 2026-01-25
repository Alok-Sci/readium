#!/bin/bash

# Script to set up GitHub secrets for CI/CD pipeline
# Make sure you have GitHub CLI (gh) installed and authenticated

echo "Setting up GitHub secrets for Readium CI/CD..."
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: You are not authenticated with GitHub CLI."
    echo "Please run: gh auth login"
    exit 1
fi

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Repository: $REPO"
echo ""

# Convert keystore to base64
echo "Converting keystore to base64..."
if [ -f "android/app/upload-keystore.jks" ]; then
    KEYSTORE_BASE64=$(base64 -w 0 android/app/upload-keystore.jks)
    echo "✓ Keystore converted"
else
    echo "Error: Keystore file not found at android/app/upload-keystore.jks"
    exit 1
fi

# Set secrets
echo ""
echo "Setting GitHub secrets..."

# KEYSTORE_BASE64
echo "$KEYSTORE_BASE64" | gh secret set KEYSTORE_BASE64
echo "✓ KEYSTORE_BASE64 set"

# KEYSTORE_PASSWORD
echo "readium2024" | gh secret set KEYSTORE_PASSWORD
echo "✓ KEYSTORE_PASSWORD set"

# KEY_PASSWORD
echo "readium2024" | gh secret set KEY_PASSWORD
echo "✓ KEY_PASSWORD set"

# KEY_ALIAS
echo "upload" | gh secret set KEY_ALIAS
echo "✓ KEY_ALIAS set"

echo ""
echo "✅ All secrets have been set successfully!"
echo ""
echo "You can verify the secrets with: gh secret list"
