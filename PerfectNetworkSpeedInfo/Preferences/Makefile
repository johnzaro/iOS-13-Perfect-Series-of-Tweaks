ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectNetworkSpeedInfoPrefs
PerfectNetworkSpeedInfoPrefs_FILES = NSPAppearanceSettings.m NSPRootHeaderView.mm NSPRootListController.xm
PerfectNetworkSpeedInfoPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectNetworkSpeedInfoPrefs_FRAMEWORKS = UIKit
PerfectNetworkSpeedInfoPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectNetworkSpeedInfoPrefs_LIBRARIES += sparkcolourpicker sparkapplist
PerfectNetworkSpeedInfoPrefs_CFLAGS += -fobjc-arc -Wno-deprecated-declarations
PerfectNetworkSpeedInfoPrefs_EXTRA_FRAMEWORKS += Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectNetworkSpeedInfoPrefs.plist$(ECHO_END)
