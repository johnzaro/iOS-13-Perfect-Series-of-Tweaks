ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2

include $(THEOS)/makefiles/common.mk

TOOL_NAME = mobileldrestart
mobileldrestart_FILES = main.m
mobileldrestart_CFLAGS = -fobjc-arc
mobileldrestart_CODESIGN_FLAGS = -Sent.xml

include $(THEOS_MAKE_PATH)/tool.mk
