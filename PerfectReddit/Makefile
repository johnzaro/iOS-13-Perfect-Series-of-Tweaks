THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

INSTALL_TARGET_PROCESSES = Reddit Preferences
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectReddit
PerfectReddit_FILES = PerfectReddit.xm
PerfectReddit_CFLAGS = -fobjc-arc
PerfectReddit_LIBRARIES = sparkcolourpicker
PerfectReddit_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk