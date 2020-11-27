ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LowPowerModeModule
LowPowerModeModule_BUNDLE_EXTENSION = bundle
LowPowerModeModule_CFLAGS = -fobjc-arc
LowPowerModeModule_FILES = LowPowerModeModule.mm
LowPowerModeModule_INSTALL_PATH = /Library/ControlCenter/Bundles/

include $(THEOS_MAKE_PATH)/bundle.mk
