ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectLockScreenPrefs
PerfectLockScreenPrefs_FILES = PLSAppearanceSettings.m PLSRootHeaderView.mm PLSRootListController.xm
PerfectLockScreenPrefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectLockScreenPrefs_FRAMEWORKS = UIKit
PerfectLockScreenPrefs_PRIVATE_FRAMEWORKS = Preferences
PerfectLockScreenPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectLockScreenPrefs_LIBRARIES += sparkcolourpicker
PerfectLockScreenPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectLockScreenPrefs.plist$(ECHO_END)
