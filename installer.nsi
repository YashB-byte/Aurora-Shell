# --- AURORA-SHELL WINDOWS INSTALLER ---
!define APPNAME "Aurora-Shell"
!define COMPANYNAME "YashB-byte"
!define DESCRIPTION "A vibrant shell theme for developers"

Name "${APPNAME}"
OutFile "Aurora-Shell-Installer.exe"
InstallDir "$PROFILE\.aurora-shell"

# Request admin execution level for Windows 10/11
RequestExecutionLevel user

Page directory
Page instfiles

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    
    # Add the theme file
    File "aurora_theme.sh" 
    
    # Create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    DetailPrint "🌈 Aurora-Shell installed successfully at $INSTDIR"
SectionEnd

# Required for the build to pass
Section "Uninstall"
    Delete "$INSTDIR\aurora_theme.sh"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"
SectionEnd