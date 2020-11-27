THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectSettings
PerfectSettings_FILES = PreferenceOrganizer2.xm PerfectSettings.xm
PerfectSettings_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
PerfectSettings_EXTRA_FRAMEWORKS += Cephei
PerfectSettings_FRAMEWORKS += IOKit
PerfectSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk