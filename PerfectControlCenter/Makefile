THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PerfectControlCenter
PerfectControlCenter_FILES = ControlCenterPreferences.mm CCModulesCustomSize.xm PerfectControlCenter.xm Init.xm
PerfectControlCenter_CFLAGS = -fobjc-arc -std=c++11 -Wno-logical-op-parentheses -Wno-c++11-extra-semi
PerfectControlCenter_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	chmod 4775 $(THEOS_STAGING_DIR)/usr/bin/mobileldrestart
	chmod 0775 layout/DEBIAN/postinst

SUBPROJECTS += LowPowerModeModule
SUBPROJECTS += PowerControlModule
SUBPROJECTS += mobileldrestart
SUBPROJECTS += Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk