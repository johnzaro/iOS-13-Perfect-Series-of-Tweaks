THEOS_DEVICE_IP = iphone
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.2:13.2

INSTALL_TARGET_PROCESSES = AppStore

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AppStoreUpdatesTab
AppStoreUpdatesTab_FILES = AppStoreUpdatesTab.xm
AppStoreUpdatesTab_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

BUNDLE_NAME = com.johnzaro.AppStoreUpdatesTab
com.johnzaro.AppStoreUpdatesTab_INSTALL_PATH = /var/mobile/Library

include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
