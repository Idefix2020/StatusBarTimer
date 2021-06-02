TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

FINALPACKAGE=0
DEBUG=1

ifeq ($(DEBUG), 1)
	GO_EASY_ON_ME=1
endif

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StatusBarTimer
StatusBarTimer_FILES = Tweak.xm
StatusBarTimer_CFLAGS = -fobjc-arc
StatusBarTimer_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
