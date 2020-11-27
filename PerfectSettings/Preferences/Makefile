ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectSettingsPrefs
PerfectSettingsPrefs_FILES = PSTAppearanceSettings.m PSTRootHeaderView.mm PSTRootListController.xm
PerfectSettingsPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectSettingsPrefs_FRAMEWORKS = UIKit
PerfectSettingsPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectSettingsPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectSettingsPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectSettingsPrefs.plist$(ECHO_END)
