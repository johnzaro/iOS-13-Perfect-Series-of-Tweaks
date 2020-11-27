THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

INSTALL_TARGET_PROCESSES = MobileSafari Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectSafari
PerfectSafari_FILES = SafariPlusFeatures.xm PerfectSafari.xm SafariPreferences.mm Init.xm
PerfectSafari_CFLAGS += -fobjc-arc
PerfectSafari_LIBRARIES += sparkcolourpicker
PerfectSafari_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk