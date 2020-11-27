ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectCursorPrefs
PerfectCursorPrefs_FILES = PCSAppearanceSettings.m PCSRootHeaderView.mm PCSRootListController.xm
PerfectCursorPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectCursorPrefs_FRAMEWORKS = UIKit
PerfectCursorPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectCursorPrefs_LIBRARIES = sparkcolourpicker
PerfectCursorPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectCursorPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectCursorPrefs.plist$(ECHO_END)
