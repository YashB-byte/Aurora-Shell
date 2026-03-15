!define APPNAME "Aurora-Shell"
Name "${APPNAME}"
OutFile "Aurora-Shell-Installer.exe"
InstallDir "$PROFILE\.aurora-shell"

Page directory
Page instfiles

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    File "aurora_theme.sh" 
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

# --- THE MISSING PIECE: THE UNINSTALLER SECTION ---
Section "Uninstall"
    Delete "$INSTDIR\aurora_theme.sh"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"
SectionEnd