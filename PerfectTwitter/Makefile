THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

INSTALL_TARGET_PROCESSES = Twitter Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectTwitter
PerfectTwitter_FILES = PerfectTwitter.xm
PerfectTwitter_CFLAGS = -fobjc-arc
PerfectTwitter_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk