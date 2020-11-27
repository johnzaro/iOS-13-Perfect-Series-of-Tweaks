ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectBTBatteryInfoPrefs
PerfectBTBatteryInfoPrefs_FILES = BBIAppearanceSettings.m BBIRootHeaderView.mm BBIRootListController.xm
PerfectBTBatteryInfoPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectBTBatteryInfoPrefs_FRAMEWORKS = UIKit
PerfectBTBatteryInfoPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectBTBatteryInfoPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectBTBatteryInfoPrefs_LIBRARIES += sparkcolourpicker sparkapplist
PerfectBTBatteryInfoPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectBTBatteryInfoPrefs.plist$(ECHO_END)
