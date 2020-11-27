THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

INSTALL_TARGET_PROCESSES = MobilePhone Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectPhone
PerfectPhone_FILES = PerfectPhone.xm
PerfectPhone_CFLAGS = -fobjc-arc -Wno-logical-op-parentheses
PerfectPhone_LIBRARIES = sparkcolourpicker
PerfectPhone_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk