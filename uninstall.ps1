# --- AURORA UNINSTALLER v4.4.7 (PowerShell) ---
$InstallPath = Join-Path $HOME ".aurora-shell_2theme"

Write-Host "⚠️ Executing Deep Clean..." -ForegroundColor Yellow

# 1. Kill the Files
if (Test-Path $InstallPath) {
    Remove-Item -Path $InstallPath -Recurse -Force -ErrorAction SilentlyContinue
}

# 2. Surgical Profile Cleaning
if (Test-Path $PROFILE) {
    $Content = Get-Content $PROFILE
    # This logic identifies the block start and end to ensure no orphaned brackets remain
    $CleanContent = $Content | Where-Object { 
        $_ -notmatch "aurora" -and 
        $_ -notmatch "Get-AuroraStats" -and
        $_ -notmatch "Show-Aurora"
    }
    $CleanContent | Set-Content $PROFILE
}

Write-Host "✅ Aurora traces purged. Restart PowerShell for a clean slate." -ForegroundColor Green