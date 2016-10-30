include theos/makefiles/common.mk

TWEAK_NAME = BLightAlert

BLightAlert_FILES = BLightAlert.xm
BLightAlert_FRAMEWORKS = CydiaSubstrate UIKit AVFoundation
BLightAlert_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
BLightAlert_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
all::
	@echo "[+] Copying Files..."
	@cp -rf ./obj/obj/debug/BLightAlert.dylib //Library/MobileSubstrate/DynamicLibraries/BLightAlert.dylib
	@/usr/bin/ldid -S //Library/MobileSubstrate/DynamicLibraries/BLightAlert.dylib
	@echo "DONE"
	@killall Music
	