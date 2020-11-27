ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectAppSwitcherPrefs
PerfectAppSwitcherPrefs_FILES = PASAppearanceSettings.m PASRootHeaderView.mm PASRootListController.xm
PerfectAppSwitcherPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectAppSwitcherPrefs_FRAMEWORKS = UIKit
PerfectAppSwitcherPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectAppSwitcherPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectAppSwitcherPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectAppSwitcherPrefs.plist$(ECHO_END)
