ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectPhotosPrefs
PerfectPhotosPrefs_FILES = PPTAppearanceSettings.m PPTRootHeaderView.mm PPTRootListController.xm
PerfectPhotosPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectPhotosPrefs_FRAMEWORKS = UIKit
PerfectPhotosPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectPhotosPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectPhotosPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectPhotosPrefs.plist$(ECHO_END)
