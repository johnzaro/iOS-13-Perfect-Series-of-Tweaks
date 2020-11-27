ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectTimePrefs
PerfectTimePrefs_FILES = DUTAppearanceSettings.m DUTRootHeaderView.mm DUTRootListController.xm
PerfectTimePrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectTimePrefs_FRAMEWORKS = UIKit
PerfectTimePrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectTimePrefs_LIBRARIES += sparkcolourpicker sparkapplist
PerfectTimePrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectTimePrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectTimePrefs.plist$(ECHO_END)
