ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectPhonePrefs
PerfectPhonePrefs_FILES = PPHAppearanceSettings.m PPHRootHeaderView.mm PPHRootListController.xm
PerfectPhonePrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectPhonePrefs_FRAMEWORKS = UIKit
PerfectPhonePrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectPhonePrefs_LIBRARIES = sparkcolourpicker
PerfectPhonePrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectPhonePrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectPhonePrefs.plist$(ECHO_END)
