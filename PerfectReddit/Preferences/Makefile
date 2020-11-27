ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectRedditPrefs
PerfectRedditPrefs_FILES = PRDAppearanceSettings.m PRDRootHeaderView.mm PRDRootListController.xm
PerfectRedditPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectRedditPrefs_FRAMEWORKS = UIKit
PerfectRedditPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectRedditPrefs_LIBRARIES = sparkcolourpicker
PerfectRedditPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectRedditPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectRedditPrefs.plist$(ECHO_END)
