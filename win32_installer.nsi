; OpenMSX install script
;
; This NSIS script creates an installation for openMSX and optionaly Catapult.
; See for license and other information about NSIS :
;
; 		http://nsis.sourceforge.net
;----------------------------------------------------------------------------------------

; Modern UI options
!include "MUI.nsh"
 
!define  MUI_COMPONENTSPAGE_SMALLDESC

Icon dist\openmsx.ico

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
Section "openMSX (required)"

  SectionIn RO

  SetOutPath $INSTDIR
  
  File /r dist\Contrib
  File /r dist\doc
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

Section "Catapult"

  File /r dist\Catapult
  
SectionEnd

Section "Start menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\openMSX"
  CreateShortCut "$SMPROGRAMS\openMSX\openMSX.lnk" "$INSTDIR\openmsx.exe" "" "$INSTDIR\openmsx.ico" 0 SW_SHOWNORMAL "" "The MSX emulator that aims for perfection" 
  
  IfFileExists $INSTDIR\Catapult\bin\catapult.exe 0 noCatapult
  CreateShortCut "$SMPROGRAMS\openMSX\Catapult.lnk" "$INSTDIR\Catapult\bin\catapult.exe" "" "$INSTDIR\Catapult\bin\catapult.exe" 0 SW_SHOWNORMAL "" "Launcher and GUI for openMSX"
  noCatapult:
  CreateShortCut "$SMPROGRAMS\openMSX\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0 SW_SHOWNORMAL "" "Uninstall openMSX and Catapult"
 
SectionEnd

Section "Uninstall"

MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Do you want to remove all userfiles and ROM's?" IDYES removeAllFiles IDNO removeOnlyInstalledFiles

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















