ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectMessengerPrefs
PerfectMessengerPrefs_FILES = PMSAppearanceSettings.m PMSRootHeaderView.mm PMSRootListController.xm
PerfectMessengerPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectMessengerPrefs_FRAMEWORKS = UIKit
PerfectMessengerPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectMessengerPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectMessengerPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectMessengerPrefs.plist$(ECHO_END)
