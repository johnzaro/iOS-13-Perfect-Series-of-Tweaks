ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectControlCenterPrefs
PerfectControlCenterPrefs_FILES = PCCAppearanceSettings.m PCCRootHeaderView.mm PCCRootListController.xm
PerfectControlCenterPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectControlCenterPrefs_FRAMEWORKS = UIKit
PerfectControlCenterPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectControlCenterPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectControlCenterPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectControlCenterPrefs.plist$(ECHO_END)
