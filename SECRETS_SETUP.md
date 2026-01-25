# GitHub Secrets Setup Guide

This guide explains how to set up the required GitHub secrets for the CI/CD pipeline.

## Prerequisites

1. **GitHub CLI (gh)** must be installed
   - Download from: https://cli.github.com/
   - Or install via package manager:
     - Windows: `winget install --id GitHub.cli`
     - macOS: `brew install gh`
     - Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md

2. **Authenticate with GitHub CLI**
   ```bash
   gh auth login
   ```
   Follow the prompts to authenticate.

## Required Secrets

The CI/CD pipeline requires these secrets:

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `KEYSTORE_BASE64` | Base64-encoded keystore file | Auto-generated from `android/app/upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Keystore password | `readium2024` |
| `KEY_PASSWORD` | Key password | `readium2024` |
| `KEY_ALIAS` | Key alias | `upload` |

## Automated Setup (Recommended)

### On Windows (PowerShell)

```powershell
.\setup-github-secrets.ps1
```

### On Linux/macOS (Bash)

```bash
chmod +x setup-github-secrets.sh
./setup-github-secrets.sh
```

The script will:
1. Check if `gh` CLI is installed and authenticated
2. Convert the keystore file to base64
3. Set all required secrets in your GitHub repository

## Manual Setup

If you prefer to set secrets manually:

### 1. Convert Keystore to Base64

**Windows (PowerShell):**
```powershell
$bytes = [System.IO.File]::ReadAllBytes("android\app\upload-keystore.jks")
$base64 = [System.Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard
Write-Host "Keystore base64 copied to clipboard"
```

**Linux/macOS:**
```bash
base64 -w 0 android/app/upload-keystore.jks | pbcopy
echo "Keystore base64 copied to clipboard"
```

### 2. Add Secrets via GitHub CLI

```bash
# Set KEYSTORE_BASE64 (paste the base64 string when prompted)
gh secret set KEYSTORE_BASE64

# Set other secrets
echo "readium2024" | gh secret set KEYSTORE_PASSWORD
echo "readium2024" | gh secret set KEY_PASSWORD
echo "upload" | gh secret set KEY_ALIAS
```

### 3. Add Secrets via GitHub Web UI

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its corresponding value

## Verify Secrets

Check that all secrets are set correctly:

```bash
gh secret list
```

You should see:
- KEYSTORE_BASE64
- KEYSTORE_PASSWORD
- KEY_PASSWORD
- KEY_ALIAS

## Security Notes

⚠️ **Important Security Considerations:**

1. **Never commit secrets to git**
   - The `.gitignore` file already excludes keystore files
   - Never commit `key.properties` or `.jks` files

2. **Rotate secrets regularly**
   - Consider changing passwords periodically
   - Update GitHub secrets when you rotate credentials

3. **Limit access**
   - Only repository admins can view/edit secrets
   - Secrets are not exposed in logs or pull requests from forks

4. **Production keystore**
   - For production releases, use a different keystore
   - Store production keystore securely (not in repository)
   - Use different passwords for production

## Troubleshooting

### "gh: command not found"
Install GitHub CLI from https://cli.github.com/

### "You are not authenticated"
Run `gh auth login` and follow the prompts

### "Keystore file not found"
Make sure you're running the script from the project root directory

### "Permission denied"
On Linux/macOS, make the script executable:
```bash
chmod +x setup-github-secrets.sh
```

## CI/CD Pipeline

Once secrets are set up, the pipeline will:

1. **On every push to main/master:**
   - Run tests
   - Analyze code
   - Build signed APK
   - Upload APK as artifact

2. **On version tags (v*):**
   - Build signed APK
   - Create GitHub release
   - Attach APK to release

### Creating a Release

To trigger a release build:

```bash
# Tag the current commit
git tag v1.0.0

# Push the tag
git push origin v1.0.0
```

The CI/CD pipeline will automatically create a GitHub release with the APK attached.
