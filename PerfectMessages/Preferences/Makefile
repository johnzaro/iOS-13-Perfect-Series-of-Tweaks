ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectMessagesPrefs
PerfectMessagesPrefs_FILES = PMEAppearanceSettings.m PMERootHeaderView.mm PMERootListController.xm
PerfectMessagesPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectMessagesPrefs_FRAMEWORKS = UIKit
PerfectMessagesPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectMessagesPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectMessagesPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectMessagesPrefs.plist$(ECHO_END)
