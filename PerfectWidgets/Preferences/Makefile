ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectWidgetsPrefs
PerfectWidgetsPrefs_FILES = PWGAppearanceSettings.m PWGRootHeaderView.mm PWGRootListController.xm
PerfectWidgetsPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectWidgetsPrefs_FRAMEWORKS = UIKit
PerfectWidgetsPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectWidgetsPrefs_LIBRARIES = sparkcolourpicker
PerfectWidgetsPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectWidgetsPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectWidgetsPrefs.plist$(ECHO_END)
