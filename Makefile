ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PurpouPanel
PurpouPanel_FILES = Tweak.xm
PurpouPanel_FRAMEWORKS = UIKit
PurpouPanel_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
