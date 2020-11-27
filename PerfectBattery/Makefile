THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectBattery
PerfectBattery_FILES = PerfectBattery.xm
PerfectBattery_CFLAGS += -fobjc-arc -Wno-deprecated-declarations
PerfectBattery_LIBRARIES += sparkcolourpicker sparkapplist
PerfectBattery_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk