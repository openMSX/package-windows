# $Id$
#
# Package openMSX and Catapult together in an NSIS installer
# =========================================================

# Default target; make sure this is always the first target in this Makefile.
MAKECMDGOALS?=default
default: all

# Name of the installer
include ../openMSX/build/version.mk
PACKAGE_FULL=$(PACKAGE_NAME)-$(PACKAGE_VERSION)-win32-bin.exe

# Name of the installer script
INSTALLER_SCRIPT=win32_installer.nsi

# Base Directories
# ================

# All created files will be inside this directory
BUILD_BASE:=derived

# All distribution files will be inside this directory
DIST_PATH=$(BUILD_BASE)/dist
FULL_DIST_PATH=$$PWD/$(DIST_PATH)
SED_DIST_PATH=$(subst /,\/,$(DIST_PATH))

# Build Rules
# ==========

all: openmsx catapult findnsis.exe w32_package

.PHONY: openmsx catapult w32_package

openmsx:
	@echo "Setting up files for openMSX"
	@OPENMSX_INSTALL=$(FULL_DIST_PATH) make -C ../openMSX install

catapult:
	@echo "Setting up files for Catapult"
	@CATAPULT_PREBUILT=true CATAPULT_INSTALL=$(FULL_DIST_PATH)/Catapult make -C ../Catapult install

findnsis.exe: findnsis.cc
	@g++ $^ -o $(BUILD_BASE)/$@

NSIS_INSTALLER_PATH=`$(BUILD_BASE)/findnsis`
NSIS_INSTALLER="$(NSIS_INSTALLER_PATH)\makensis.exe"

w32_package:
	@mv $(FULL_DIST_PATH)/bin/openmsx.exe $(FULL_DIST_PATH)
	@rm -rf $(FULL_DIST_PATH)/bin
ifeq ($(ADDFILES_PATH),)
	@$(error Please set the ADDFILES_PATH environment variable)
endif
	@cp -Rf $(ADDFILES_PATH)/* $(FULL_DIST_PATH)
	@find $(DIST_PATH) -name "*" -type f | sed -e 's/$(SED_DIST_PATH)\//Delete $$INSTDIR\\/' -e \
	's/\//\\/g' > $(BUILD_BASE)/RemoveFileList.nsh
	@find $(DIST_PATH) -name "*" -type d | sort -r | sed -e 's/$(SED_DIST_PATH)\//RMDir $$INSTDIR\\/' \
	-e '$$d' -e 's/\//\\/g'  >> $(BUILD_BASE)/RemoveFileList.nsh
	@cp -f win32_installer.nsi $(BUILD_BASE)
	@cp -f integrate.ini $(BUILD_BASE)
	@echo "Creating installer: $(PACKAGE_FULL)"
	@$(NSIS_INSTALLER) //V2 "//XOutFile $(PACKAGE_FULL)" $(BUILD_BASE)/$(INSTALLER_SCRIPT)

