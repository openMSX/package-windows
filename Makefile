# $Id$
#
# Package openMSX and Catapult together in an NSIS installer
# =========================================================

# Default target; make sure this is always the first target in this Makefile.
MAKECMDGOALS?=default
default: all 

# Base Directories
# ================

# All created files will be inside this directory
BUILD_BASE:=derived

# All global Makefiles are inside this directory
MAKE_PATH:=build

# Build Rules
# ==========

all: openmsx catapult findnsis.exe w32_package 

.PHONY: openmsx catapult w32_package

openmsx:
	OPENMSX_INSTALL=$$PWD/derived make -C ../openMSX install
	
catapult:
	DONOTBUILD=yes CATAPULT_INSTALL=$$PWD/derived/Catapult make -C ../Catapult install
	
findnsis.exe: findnsis.cc
	@g++ $^ -o $@

NSIS_INSTALLER_PATH=`findnsis`
NSIS_INSTALLER=$(NSIS_INSTALLER_PATH)/makensisw.exe

w32_package:
	@mv derived/bin/openmsx.exe derived
	@rm -r derived/bin
ifeq ($(ADDFILES_PATH),)
	$(error Please set the ADDFILES_PATH environment variable)
endif
	@cp -R $(ADDFILES_PATH)/* derived
	@find derived -name "*" -type f | sed -e 's/derived\//Delete $$INSTDIR\\/' -e \
	's/\//\\/g' > RemoveFileList.nsh
	@find derived -name "*" -type d | sort -r | sed -e 's/derived\//RMDir $$INSTDIR\\/' \
	-e '$$d' -e 's/\//\\/g'  >> RemoveFileList.nsh	
	@$(NSIS_INSTALLER) win32_installer.nsi

