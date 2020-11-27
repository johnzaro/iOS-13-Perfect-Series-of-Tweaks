ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PowerControlModule
PowerControlModule_BUNDLE_EXTENSION = bundle
PowerControlModule_CFLAGS = -fobjc-arc -Iheaders
PowerControlModule_FILES = PowerControlModule.mm
PowerControlModule_LDFLAGS = ../Frameworks/ControlCenterUIKit.tbd
PowerControlModule_INSTALL_PATH = /Library/ControlCenter/Bundles/
PowerControlModule_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/bundle.mk
