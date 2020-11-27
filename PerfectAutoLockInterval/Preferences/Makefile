ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectAutoLockIntervalPrefs
PerfectAutoLockIntervalPrefs_FILES = CLIAppearanceSettings.m CLIRootHeaderView.mm CLIRootListController.xm
PerfectAutoLockIntervalPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectAutoLockIntervalPrefs_FRAMEWORKS = UIKit
PerfectAutoLockIntervalPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectAutoLockIntervalPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectAutoLockIntervalPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectAutoLockIntervalPrefs.plist$(ECHO_END)
