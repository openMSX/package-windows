; OpenMSX install script
;
; This NSIS script creates an installation for openMSX and optionally Catapult.
; See for license and other information about NSIS :
;
; 		http://nsis.sourceforge.net
;----------------------------------------------------------------------------------------

Icon dist\openmsx.ico

; Modern UI options
!include "MUI.nsh"

!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_ICON dist\openmsx.ico
!define MUI_UNICON dist\openmsx.ico

; The name of the installer
Name "openMSX"

; The default installation directory
InstallDir $PROGRAMFILES\openMSX

;--------------------------------
; Pages

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
Page custom UninstallIntegration
!insertmacro MUI_PAGE_INSTFILES

 !insertmacro MUI_UNPAGE_CONFIRM
 !insertmacro MUI_UNPAGE_INSTFILES
;--------------------------------
; Select Language

!insertmacro MUI_LANGUAGE "English"
;--------------------------------
; Reserve space for the ini-files

ReserveFile "integrate.ini"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
;---------------------------------
; declare global variables

Var "Integrate"

;--------------------------------
Section "openMSX (required)" SecOpenMSX

  SectionIn RO

  SetOutPath $INSTDIR

  File /r dist\codec
  File /r /x Catapult dist\doc
  File /r dist\doc.dll
  File /r dist\share
  File dist\*.*

  IntCmp $Integrate 0 NoIntegration 0
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\openMSX" "DisplayName" "openMSX"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\openMSX" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\openMSX" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\openMSX" "NoRepair" 1
  noIntegration:
  WriteUninstaller "uninstall.exe"

SectionEnd

Section "Catapult" SecCatapult

  File /r dist\Catapult

SectionEnd

Section "Start menu Shortcuts" SecShortcuts

  CreateDirectory "$SMPROGRAMS\openMSX"
  CreateShortCut "$SMPROGRAMS\openMSX\openMSX.lnk" "$INSTDIR\openmsx.exe" "" "$INSTDIR\openmsx.ico" 0 SW_SHOWNORMAL "" "The MSX emulator that aims for perfection"
  CreateShortCut "$SMPROGRAMS\openMSX\openMSX Manual.lnk" "$INSTDIR\doc\manual\index.html" "" "" 0 SW_SHOWNORMAL "" "openMSX manual"

  SetOutPath "$INSTDIR\codec"
  ClearErrors
  ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
  IfErrors we_9x we_nt
  we_nt:
  CreateShortCut "$SMPROGRAMS\openMSX\Install videoplayer codec.lnk" "rundll32" "setupapi,InstallHinfSection DefaultInstall 128 $INSTDIR\codec\zmbv.inf"
  goto endCodec
  we_9x:
  CreateShortCut "$SMPROGRAMS\openMSX\Install videoplayer codec.lnk" "rundll" "setupx.dll,InstallHinfSection DefaultInstall 128 $INSTDIR\codec\zmbv.inf"
  endCodec:
  SetOutPath $INSTDIR

  IfFileExists $INSTDIR\Catapult\bin\catapult.exe 0 noCatapult
  CreateShortCut "$SMPROGRAMS\openMSX\Catapult.lnk" "$INSTDIR\Catapult\bin\catapult.exe" "" "$INSTDIR\Catapult\bin\catapult.exe" 0 SW_SHOWNORMAL "" "Launcher and GUI for openMSX"
  CreateShortCut "$SMPROGRAMS\openMSX\Catapult Manual.lnk" "$INSTDIR\Catapult\doc\manual\index.html" "" "" 0 SW_SHOWNORMAL "" "openMSX Catapult manual"
  noCatapult:
  CreateShortCut "$SMPROGRAMS\openMSX\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0 SW_SHOWNORMAL "" "Uninstall openMSX and Catapult"

SectionEnd

;--------------------------------
; Descriptions

; Language strings
LangString DESC_SecOpenMSX ${LANG_ENGLISH} "The MSX emulator that aims for perfection."
LangString DESC_SecCatapult ${LANG_ENGLISH} "The GUI and launcher for openMSX."
LangString DESC_SecShortcuts ${LANG_ENGLISH} "Create startmenu shortcuts for openMSX and Catapult."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecOpenMSX} $(DESC_SecOpenMSX)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCatapult} $(DESC_SecCatapult)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} $(DESC_SecShortcuts)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section "Uninstall"

MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Do you want to remove all user files and ROMs?" IDYES removeAllFiles IDNO removeOnlyInstalledFiles

removeAllFiles:
  RMDir /r "$INSTDIR"
  Goto removeRegKey
removeOnlyInstalledFiles:
  Delete "$INSTDIR\Uninstall.exe"
  !include "RemoveFileList.nsh"
  RMDir "$INSTDIR"
removeRegKey:
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\openMSX"

  IfFileExists $SMPROGRAMS\openMSX 0 noRemoveShortCuts
  RMDir /r "$SMPROGRAMS\openMSX"
noRemoveShortCuts:

SectionEnd
;-----------------------------------------------------
;functions

Function .onInit

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "integrate.ini"

FunctionEnd

Function UninstallIntegration

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "integrate.ini"
  !insertmacro MUI_INSTALLOPTIONS_READ $Integrate "integrate.ini" "Field 2" "State"

FunctionEnd

Function .onInstSuccess
    MessageBox MB_OK "If you want to emulate real MSX systems and not only the free C-BIOS machines, put the system ROMs in the following directory: $\r$OUTDIR\share\systemroms"

FunctionEnd
