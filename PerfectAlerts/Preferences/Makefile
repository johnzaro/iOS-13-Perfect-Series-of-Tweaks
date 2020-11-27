ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectAlertsPrefs
PerfectAlertsPrefs_FILES = PALAppearanceSettings.m PALRootHeaderView.mm PALRootListController.xm
PerfectAlertsPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectAlertsPrefs_FRAMEWORKS = UIKit
PerfectAlertsPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectAlertsPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectAlertsPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectAlertsPrefs.plist$(ECHO_END)
