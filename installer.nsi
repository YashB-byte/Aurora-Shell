!define APPNAME "Aurora-Shell"
!define COMPANYNAME "YashB-byte"

Name "${APPNAME}"
OutFile "Aurora-Shell-Installer.exe"
InstallDir "$PROFILE\.aurora-shell"

RequestExecutionLevel user

Page directory
Page instfiles

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    File "aurora_theme.sh" 
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\aurora_theme.sh"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"
SectionEnd