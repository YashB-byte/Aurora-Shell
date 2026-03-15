!define APPNAME "Aurora-Shell"
Name "${APPNAME}"
OutFile "Aurora-Shell-Installer.exe"
InstallDir "$PROFILE\.aurora-shell"

Page directory
Page instfiles

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    # This must match your theme filename exactly
    File "aurora_theme.sh" 
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd