ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PerfectRAMInfo13Prefs
PerfectRAMInfo13Prefs_FILES = RINAppearanceSettings.m RINRootHeaderView.mm RINRootListController.xm
PerfectRAMInfo13Prefs_INSTALL_PATH = /Library/PreferenceBundles
PerfectRAMInfo13Prefs_FRAMEWORKS = UIKit
PerfectRAMInfo13Prefs_PRIVATE_FRAMEWORKS = Preferences
PerfectRAMInfo13Prefs_LIBRARIES += sparkcolourpicker sparkapplist
PerfectRAMInfo13Prefs_CFLAGS += -fobjc-arc -Wno-deprecated-declarations
PerfectRAMInfo13Prefs_EXTRA_FRAMEWORKS += Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PerfectRAMInfo13Prefs.plist$(ECHO_END)
