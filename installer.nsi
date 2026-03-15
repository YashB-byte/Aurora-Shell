# --- AURORA-SHELL UNIVERSAL WINDOWS INSTALLER ---
!define APPNAME "Aurora-Shell"

Name "${APPNAME}"
OutFile "Aurora-Shell-Installer.exe"
InstallDir "$PROFILE\.aurora-shell"

Page directory
Page instfiles

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    
    # This is the "Magic" line: /r tells NSIS to search subfolders 
    # if it doesn't find the file in the root.
    File /r "aurora_theme.sh" 
    
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd