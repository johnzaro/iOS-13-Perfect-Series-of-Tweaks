ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectMusicPrefs
PerfectMusicPrefs_FILES = PMUAppearanceSettings.m PMURootHeaderView.mm PMURootListController.xm
PerfectMusicPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectMusicPrefs_FRAMEWORKS = UIKit
PerfectMusicPrefs_LIBRARIES += sparkcolourpicker
PerfectMusicPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectMusicPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectMusicPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectMusicPrefs.plist$(ECHO_END)
