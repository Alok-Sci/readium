# Script to set up GitHub secrets for CI/CD pipeline
# Make sure you have GitHub CLI (gh) installed and authenticated

Write-Host "Setting up GitHub secrets for Readium CI/CD..." -ForegroundColor Cyan
Write-Host ""

# Check if gh is installed
try {
    $null = Get-Command gh -ErrorAction Stop
} catch {
    Write-Host "Error: GitHub CLI (gh) is not installed." -ForegroundColor Red
    Write-Host "Please install it from: https://cli.github.com/"
    exit 1
}

# Check if user is authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: You are not authenticated with GitHub CLI." -ForegroundColor Red
    Write-Host "Please run: gh auth login"
    exit 1
}

# Get repository info
$repo = gh repo view --json nameWithOwner -q .nameWithOwner
Write-Host "Repository: $repo" -ForegroundColor Green
Write-Host ""

# Convert keystore to base64
Write-Host "Converting keystore to base64..."
$keystorePath = "android\app\upload-keystore.jks"
if (Test-Path $keystorePath) {
    $keystoreBytes = [System.IO.File]::ReadAllBytes($keystorePath)
    $keystoreBase64 = [System.Convert]::ToBase64String($keystoreBytes)
    Write-Host "✓ Keystore converted" -ForegroundColor Green
} else {
    Write-Host "Error: Keystore file not found at $keystorePath" -ForegroundColor Red
    exit 1
}

# Set secrets
Write-Host ""
Write-Host "Setting GitHub secrets..."

# KEYSTORE_BASE64
$keystoreBase64 | gh secret set KEYSTORE_BASE64
Write-Host "✓ KEYSTORE_BASE64 set" -ForegroundColor Green

# KEYSTORE_PASSWORD
"readium2024" | gh secret set KEYSTORE_PASSWORD
Write-Host "✓ KEYSTORE_PASSWORD set" -ForegroundColor Green

# KEY_PASSWORD
"readium2024" | gh secret set KEY_PASSWORD
Write-Host "✓ KEY_PASSWORD set" -ForegroundColor Green

# KEY_ALIAS
"upload" | gh secret set KEY_ALIAS
Write-Host "✓ KEY_ALIAS set" -ForegroundColor Green

Write-Host ""
Write-Host "✅ All secrets have been set successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "You can verify the secrets with: gh secret list" -ForegroundColor Yellow
