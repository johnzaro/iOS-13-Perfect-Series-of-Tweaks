ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectYoutubePrefs
PerfectYoutubePrefs_FILES = PYTAppearanceSettings.m PYTRootHeaderView.mm PYTRootListController.xm
PerfectYoutubePrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectYoutubePrefs_FRAMEWORKS = UIKit
PerfectYoutubePrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectYoutubePrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectYoutubePrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectYoutubePrefs.plist$(ECHO_END)
