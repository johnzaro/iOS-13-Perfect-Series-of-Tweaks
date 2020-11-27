THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang::11.2

INSTALL_TARGET_PROCESSES = SpringBoard
# INSTALL_TARGET_PROCESSES = Music Preferences
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectMusic
PerfectMusic_FILES = $(wildcard *.xm *.mm *.m)
PerfectMusic_CFLAGS = -fobjc-arc -Wno-logical-op-parentheses -Wno-unguarded-availability-new
PerfectMusic_EXTRA_FRAMEWORKS += Cephei
PerfectMusic_LIBRARIES += sparkcolourpicker
PerfectMusic_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk