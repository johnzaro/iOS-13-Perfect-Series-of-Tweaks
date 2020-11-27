THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone::13.2:13.2

INSTALL_TARGET_PROCESSES = Messenger Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectMessenger
PerfectMessenger_FILES = PerfectMessenger.xm
PerfectMessenger_CFLAGS = -fobjc-arc
PerfectMessenger_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk