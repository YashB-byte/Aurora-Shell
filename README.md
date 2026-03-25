<a href="https://github.com/YashB-byte/aurora-shell" style="
  display:inline-block;
  padding:8px 16px;
  background:#2da44e;
  color:white;
  border-radius:6px;
  font-weight:600;
  text-decoration:none;
  font-family:system-ui,-apple-system,Segoe UI,Helvetica,Arial,sans-serif;
">
  Join the Dev Beta Program
</a>

**to install**
```bash
bash <(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/dev/install.sh)
```
or for dev branch:
```bash
bash <(curl -s https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/dev/install.sh)
```
run with "```-v```" at the end of command to see everything that is going on

🪟 For Windows (PowerShell 7+)

> [!IMPORTANT]
> This theme requires Microsoft PowerShell 7.0 or higher. It is not compatible with Microsoft Windows PowerShell 5.1.

**Install PowerShell 7 (if needed):**
```powershell
winget install Microsoft.PowerShell
```

Or for PowerShell Preview:
```powershell
winget install Microsoft.PowerShell.Preview
```

**command line install**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/dev/install.ps1'))
```

📦 **Dependencies**

macOS requires `lolcat` for colorful output:
```bash
brew install lolcat
```

🛠️ Customization
The main configuration logic is stored in:

Mac: ~/.aurora-shell_files (sourced in your .zshrc)

Windows: $PROFILE (usually located in Documents\PowerShell\Microsoft.PowerShell_profile.ps1)

🗑️ Uninstall

To remove Aurora Shell on MacOS:
```bash
shell.aurora --uninstall
```
 
or for windows:
```powershell
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/YashB-byte/aurora-shell-2/dev/uninstall.ps1" | PowerShell -ExecutionPolicy Bypass -Command -
```
thank you!
