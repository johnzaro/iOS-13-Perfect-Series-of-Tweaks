ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectNotificationsPrefs
PerfectNotificationsPrefs_FILES = PNCAppearanceSettings.m PNCRootHeaderView.mm PNCRootListController.xm
PerfectNotificationsPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectNotificationsPrefs_FRAMEWORKS = UIKit
PerfectNotificationsPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectNotificationsPrefs_LIBRARIES = sparkcolourpicker
PerfectNotificationsPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectNotificationsPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectNotificationsPrefs.plist$(ECHO_END)
