ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1
THEOS_DEVICE_IP = 192.168.0.17

ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET = iphone:16.5:15.0
CFLAGS += -DNEW_API
else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
TARGET = iphone:16.5:15.0
CFLAGS += -DNEW_API
else
export PREFIX=$(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
TARGET = iphone:14.5:13.0
endif

INSTALL_TARGET_PROCESSES = Snapchat Preferences

TWEAK_NAME = SecretShot
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

SUBPROJECTS = SecretShotPreferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
