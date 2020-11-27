ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectBatteryPrefs
PerfectBatteryPrefs_FILES = PBTAppearanceSettings.m PBTRootHeaderView.mm PBTRootListController.xm
PerfectBatteryPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectBatteryPrefs_FRAMEWORKS = UIKit
PerfectBatteryPrefs_PRIVATE_FRAMEWORKS += Preferences
PerfectBatteryPrefs_LIBRARIES += sparkcolourpicker sparkapplist
PerfectBatteryPrefs_CFLAGS += -fobjc-arc -Wno-deprecated-declarations
PerfectBatteryPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectBatteryPrefs.plist$(ECHO_END)
