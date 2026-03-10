# --- AURORA SYSTEM INSTALLER v4.4.7 (PowerShell) ---
# Optimization: Dynamic Centering & Secure Credential Handling

# 0. CHECK POWERSHELL VERSION
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "❌ PowerShell 7+ required. Installing..." -ForegroundColor Red
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Microsoft.PowerShell
        Write-Host "✅ PowerShell 7 installed. Please restart and run this again." -ForegroundColor Green
        exit
    } else {
        Write-Host "❌ Please install PowerShell 7 manually: https://aka.ms/powershell" -ForegroundColor Red
        exit 1
    }
}

$InstallPath = Join-Path $HOME ".aurora-shell_2theme"

# 1. PASSWORD SETUP
if ($env:PRESERVED_PASSWORD) {
    Write-Host "🔄 Preserving existing password..." -ForegroundColor Cyan
    $PlainPass = $env:PRESERVED_PASSWORD
} else {
    Write-Host "🌌 Aurora Setup: Set your Terminal Lock Password" -ForegroundColor Magenta
    $NewPass = Read-Host -AsSecureString "Set new Terminal Password"
    $ConfirmPass = Read-Host -AsSecureString "Confirm Password"

    $BSTR1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPass)
    $PlainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR1)

    $BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConfirmPass)
    $PlainConfirm = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)

    if ($PlainPass -ne $PlainConfirm) {
        Write-Host "❌ Passwords do not match. Installation aborted." -ForegroundColor Red
        exit 1
    }
}

# 2. FILE SETUP (PURGE & CLONE)
if (Test-Path $InstallPath) {
    Write-Host "🧹 Purging old Aurora files..." -ForegroundColor Yellow
    Remove-Item -Path $InstallPath -Recurse -Force
}
New-Item -Path $InstallPath -ItemType Directory | Out-Null

Write-Host "📥 Cloning Aurora Shell..." -ForegroundColor Cyan
$RepoPath = Join-Path $InstallPath "repo"
git clone --progress https://github.com/YashB-byte/aurora-shell-2.git $RepoPath

# 3. GENERATE THEME FILE
$ThemeFile = Join-Path $InstallPath "aurora_theme.ps1"

$ThemeScript = @'
$CORRECT_PASSWORD = "PASSWORD_PLACEHOLDER"

function Show-AuroraLock {
    Write-Host "🔐 Aurora Terminal Lock" -ForegroundColor Magenta
    $Attempts = 0
    while ($Attempts -lt 3) {
        $ui = Read-Host -AsSecureString "Password"
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ui)
        $InputPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        if ($InputPass -eq $CORRECT_PASSWORD) {
            Write-Host "✅ Access Granted." -ForegroundColor Green
            return
        } else {
            $Attempts++
            Write-Host "❌ Incorrect. $((3-$Attempts)) left." -ForegroundColor Yellow
            if ($Attempts -eq 3) { exit }
        }
    }
}

function Show-AuroraDisplay {
    # System Stats
    $Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue).EstimatedChargeRemaining
    $BatteryStr = if (-not $Battery) { "AC" } else { "$Battery%" }
    $Cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 2)
    $Disk = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
    $DateStr = (Get-Date).ToShortDateString()

    # Dynamic Centering Logic
    $WindowWidth = $Host.UI.RawUI.WindowSize.Width
    $StatsLine = "📅 $DateStr | 🔋 $BatteryStr | 🧠 CPU: $Cpu% | 💽 ${Disk}GB Free"
    $Separator = "------------------------------------------------------------"
    
    $StatsPadding = [math]::Max(0, [int](($WindowWidth - $StatsLine.Length) / 2))
    $SepPadding = [math]::Max(0, [int](($WindowWidth - $Separator.Length) / 2))

    $Ascii = @"
              █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ 
             ██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗
             ███████║██║   ██║██████╔╝██║   ██║██████╔╝███████║
             ██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██║
             ██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║██║  ██║
             ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
                                                               
                 ███████╗██╗  ██╗███████╗██╗     ██╗                
                 ██╔════╝██║  ██║██╔════╝██║     ██║                
                 ███████╗███████║█████╗  ██║     ██║                
                 ╚════██║██╔══██║██╔══╝  ██║     ██║                
                 ███████║██║  ██║███████╗███████╗███████╗          
                 ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
"@
    Write-Host $Ascii -ForegroundColor Cyan
    Write-Host (" " * $StatsPadding + $StatsLine) -ForegroundColor Cyan
    Write-Host (" " * $SepPadding + $Separator) -ForegroundColor Cyan
    Write-Host ""
}

# STARTUP
Clear-Host
Show-AuroraLock
Show-AuroraDisplay
'@

# Inject password and save
$ThemeScript.Replace('PASSWORD_PLACEHOLDER', $PlainPass) | Out-File -FilePath $ThemeFile -Encoding utf8

# 4. LINK TO PROFILE
if (-not (Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force | Out-Null }
$ProfileContent = Get-Content $PROFILE
if ($ProfileContent -notmatch "aurora_theme.ps1") {
    Add-Content -Path $PROFILE -Value "`n. `"$ThemeFile`""
}

Write-Host "✨ Aurora v4.4.7 (Windows Edition) installed!" -ForegroundColor Green
Write-Host "🔄 Restart terminal to activate." -ForegroundColor Cyangit clone https://github.com/YashB-byte/aurora-shell-2.git $RepoPath

if (-not (Test-Path $RepoPath)) {
    Write-Host "❌ Git clone failed. Installation aborted." -ForegroundColor Red
    exit 1
}

# 5. GENERATE THEME FILE
$ThemeFile = Join-Path $InstallPath "aurora_theme.ps1"

# Create theme file content
$ThemeScript = @'
$CORRECT_PASSWORD = "PASSWORD_PLACEHOLDER"

function Show-AuroraLock {
    Write-Host "🔐 Aurora Terminal Lock" -ForegroundColor Magenta
    $Attempts = 0
    while ($Attempts -lt 3) {
        $ui = Read-Host -AsSecureString "Password"
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ui)
        $InputPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        if ($InputPass -eq $CORRECT_PASSWORD) {
            Write-Host "✅ Access Granted." -ForegroundColor Green
            return
        } else {
            $Attempts++
            if ($Attempts -lt 3) {
                Write-Host "❌ Incorrect. $((3-$Attempts)) left." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            } else {
                Write-Host "❌ Denied." -ForegroundColor Red
                exit
            }
        }
    }
}

function Show-AuroraDisplay {
    $Battery = (Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue).EstimatedChargeRemaining
    if (-not $Battery) { $Battery = "AC" } else { $Battery = "$Battery%" }
    
    $Cpu = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples.CookedValue, 2)
    $Disk = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
    
    Write-Host " █████╗ ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ " -ForegroundColor Cyan
    Write-Host "██╔══██╗██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗" -ForegroundColor Cyan
    Write-Host "███████║██║   ██║██████╔╝██║   ██║██████╔╝███████║" -ForegroundColor Cyan
    Write-Host "██╔══██║██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══██║" -ForegroundColor Cyan
    Write-Host "██║  ██║╚██████╔╝██║  ██║╚██████╔╝██║  ██║██║  ██║" -ForegroundColor Cyan
    Write-Host "╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝" -ForegroundColor Cyan
    Write-Host "" -ForegroundColor Cyan
    Write-Host "     ███████╗██╗  ██╗███████╗██╗     ██╗      " -ForegroundColor Cyan
    Write-Host "     ██╔════╝██║  ██║██╔════╝██║     ██║      " -ForegroundColor Cyan
    Write-Host "     ███████╗███████║█████╗  ██║     ██║      " -ForegroundColor Cyan
    Write-Host "     ╚════██║██╔══██║██╔══╝  ██║     ██║      " -ForegroundColor Cyan
    Write-Host "     ███████║██║  ██║███████╗███████╗███████╗ " -ForegroundColor Cyan
    Write-Host "     ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝" -ForegroundColor Cyan
    Write-Host "📅 $((Get-Date).ToShortDateString()) | 🔋 $Battery | 🧠 CPU: $Cpu% | 💽 ${Disk}GB Free" -ForegroundColor Cyan
    Write-Host "--------------------------------------" -ForegroundColor Cyan
}

function aurora {
    param([string]$Command)
    
    switch ($Command) {
        'lock' { 
            Clear-Host
            Show-AuroraLock
            Show-AuroraDisplay
        }
        'pass' {
            $op = Read-Host -AsSecureString 'Current Pass'
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($op)
            $CurrentInput = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            
            if ($CurrentInput -eq $CORRECT_PASSWORD) {
                $np = Read-Host -AsSecureString 'New Pass'
                $BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($np)
                $NewInput = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)
                
                $ThemePath = Join-Path $env:USERPROFILE '.aurora-shell_2theme\aurora_theme.ps1'
                (Get-Content $ThemePath) -replace 'CORRECT_PASSWORD = ".*"', "CORRECT_PASSWORD = `"$NewInput`"" | Set-Content $ThemePath
                $global:CORRECT_PASSWORD = $NewInput
                Write-Host '✅ Password updated!' -ForegroundColor Green
            } else {
                Write-Host '❌ Wrong password.' -ForegroundColor Red
            }
        }
        'update' {
            $verify = Read-Host -AsSecureString 'Enter password to update'
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($verify)
            $VerifyInput = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            
            if ($VerifyInput -ne $CORRECT_PASSWORD) {
                Write-Host '❌ Incorrect password. Update cancelled.' -ForegroundColor Red
                return
            }
            
            Write-Host '🔄 Updating Aurora Shell from main branch...' -ForegroundColor Magenta
            $TempInstaller = [System.IO.Path]::GetTempFileName() + '.ps1'
            Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/main/install.ps1' -OutFile $TempInstaller
            $env:PRESERVED_PASSWORD = $CORRECT_PASSWORD
            & $TempInstaller
            Remove-Item $TempInstaller
        }
        default {
            Write-Host '🌌 Aurora Command Center' -ForegroundColor Magenta
            Write-Host '---------------------------------------'
            Write-Host '🚀 [1] lock   : Re-engage terminal lock'
            Write-Host '🔑 [2] pass   : Change password'
            Write-Host '🔄 [3] update : Update Aurora Shell'
            Write-Host ''
            Write-Host 'Usage: aurora lock | aurora pass | aurora update'
        }
    }
}

Show-AuroraLock
Show-AuroraDisplay
'@

# Replace placeholder and write file
$ThemeScript -replace 'PASSWORD_PLACEHOLDER', $PlainPass | Out-File -FilePath $ThemeFile -Encoding utf8

# 6. LINK TO PROFILE
if (-not (Test-Path $PROFILE)) { 
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null 
}

if (-not (Select-String -Path $PROFILE -Pattern "aurora_theme.ps1" -Quiet)) {
    Add-Content -Path $PROFILE -Value "`n. `"$ThemeFile`""
}

# 7. SOURCE SHELL.AURORA COMMANDS
$ShellAuroraPath = Join-Path $RepoPath "shell.aurora"
if (Test-Path $ShellAuroraPath) {
    if (-not (Select-String -Path $PROFILE -Pattern "shell.aurora" -Quiet)) {
        Add-Content -Path $PROFILE -Value ". `"$ShellAuroraPath`""
    }
}

Write-Host "✨ Aurora Shell v4.4.7 installed successfully!" -ForegroundColor Green
Write-Host "🔄 Restart your terminal to activate." -ForegroundColor Cyan
