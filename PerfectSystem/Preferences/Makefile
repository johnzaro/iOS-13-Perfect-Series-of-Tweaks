ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectSystemPrefs
PerfectSystemPrefs_FILES = PSSAppearanceSettings.m PSSRootHeaderView.mm PSSRootListController.xm
PerfectSystemPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectSystemPrefs_FRAMEWORKS = UIKit
PerfectSystemPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectSystemPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectSystemPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectSystemPrefs.plist$(ECHO_END)
