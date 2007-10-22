# $Id$
#
# Package openMSX and Catapult together in an NSIS installer
# =========================================================

# Default target; make sure this is always the first target in this Makefile.
MAKECMDGOALS?=default
default: all

# Check if the stuff is in a different directory
OPENMSX_PATH?=../openMSX
CATAPULT_PATH?=../Catapult

# Name of the installer
include $(OPENMSX_PATH)/build/version.mk
PACKAGE_FULL=$(PACKAGE_NAME)-$(PACKAGE_VERSION)-win32-bin.exe

# Make this flavour for the package
export OPENMSX_FLAVOUR:=i686
export CATAPULT_FLAVOUR:=i686

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
	@echo "  Making static build..."
	@make -C $(OPENMSX_PATH) staticbindist OPENMSX_FLAVOUR=$(OPENMSX_FLAVOUR)
	@echo "  Copying results to target directory..."
	@mkdir -p $(FULL_DIST_PATH)
	@cp -Rf $(OPENMSX_PATH)/derived/x86-mingw32-$(OPENMSX_FLAVOUR)-3rd/bindist/install/* $(FULL_DIST_PATH)
	@echo "  Copy ico version of icon to target directory..."
	@cp $(OPENMSX_PATH)/src/resource/openmsx.ico $(FULL_DIST_PATH)/share/icons

catapult:
	@echo "Setting up files for Catapult"
	@echo "  Making build..."
	@CATAPULT_INSTALL=$(FULL_DIST_PATH)/Catapult make -C $(CATAPULT_PATH) install

findnsis.exe: findnsis.cc
	@g++ $^ -o $(BUILD_BASE)/$@

NSIS_INSTALLER_PATH=`$(BUILD_BASE)/findnsis`
NSIS_INSTALLER="$(NSIS_INSTALLER_PATH)\makensis.exe"

w32_package:
	@rm -rf $(FULL_DIST_PATH)/bin
ifeq ($(ADDFILES_PATH),)
	@$(error Please set the ADDFILES_PATH environment variable)
endif
# copy the addfiles stuff
	@cp -Rf $(ADDFILES_PATH)/* $(FULL_DIST_PATH)
# copy the codec to the target dir, without svn admin stuff (reuse openMSX script)
	@$(OPENMSX_PATH)/build/install-recursive.sh $(BUILD_BASE)/../ $(BUILD_BASE)/../codec $(FULL_DIST_PATH)
	@find $(DIST_PATH) -name "*" -type f | sed -e 's/$(SED_DIST_PATH)\//Delete $$INSTDIR\\/' -e \
	's/\//\\/g' > $(BUILD_BASE)/RemoveFileList.nsh
	@find $(DIST_PATH) -name "*" -type d | sort -r | sed -e 's/$(SED_DIST_PATH)\//RMDir $$INSTDIR\\/' \
	-e '$$d' -e 's/\//\\/g'  >> $(BUILD_BASE)/RemoveFileList.nsh
	@cp -f win32_installer.nsi $(BUILD_BASE)
	@cp -f integrate.ini $(BUILD_BASE)
	@echo "Creating installer: $(PACKAGE_FULL)"
	@$(NSIS_INSTALLER) //V2 "//XOutFile $(PACKAGE_FULL)" $(BUILD_BASE)/$(INSTALLER_SCRIPT)
