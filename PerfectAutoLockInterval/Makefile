THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectAutoLockInterval
PerfectAutoLockInterval_FILES = PerfectAutoLockInterval.xm
PerfectAutoLockInterval_CFLAGS = -fobjc-arc
PerfectAutoLockInterval_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk