ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectTwitterPrefs
PerfectTwitterPrefs_FILES = PTWAppearanceSettings.m PTWRootHeaderView.mm PTWRootListController.xm
PerfectTwitterPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectTwitterPrefs_FRAMEWORKS = UIKit
PerfectTwitterPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectTwitterPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectTwitterPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectTwitterPrefs.plist$(ECHO_END)
