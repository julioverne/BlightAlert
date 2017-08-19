include theos/makefiles/common.mk

TWEAK_NAME = BLightAlert

BLightAlert_FILES = /mnt/d/codes/blightalert/blightalerthook/BLightAlert.xm
BLightAlert_FRAMEWORKS = CydiaSubstrate UIKit AVFoundation
BLightAlert_PRIVATE_FRAMEWORKS =BackBoardServices
BLightAlert_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
BLightAlert_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
all::
	