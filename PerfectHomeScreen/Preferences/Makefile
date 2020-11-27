ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectHomeScreenPrefs
PerfectHomeScreenPrefs_FILES = PHSAppearanceSettings.m PHSRootHeaderView.mm PHSRootListController.xm
PerfectHomeScreenPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectHomeScreenPrefs_FRAMEWORKS = UIKit
PerfectHomeScreenPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectHomeScreenPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectHomeScreenPrefs_LIBRARIES += sparkapplist sparkcolourpicker
PerfectHomeScreenPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectHomeScreenPrefs.plist$(ECHO_END)
