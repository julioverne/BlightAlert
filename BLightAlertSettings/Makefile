include ../theos/makefiles/common.mk

BUNDLE_NAME = BLightAlertSettings
BLightAlertSettings_FILES = BLightAlertSettingsController.mm
BLightAlertSettings_INSTALL_PATH = /Library/PreferenceBundles
BLightAlertSettings_FRAMEWORKS = UIKit QuartzCore CoreGraphics MessageUI Social Twitter
BLightAlertSettings_PRIVATE_FRAMEWORKS = Preferences
BLightAlertSettings_CFLAGS = -fobjc-arc
BLightAlertSettings_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include ../theos/makefiles/bundle.mk

all::
	@echo "[+] Copying Files..."
	@cp ./obj/obj/debug/BLightAlertSettings.bundle/BLightAlertSettings //Library/PreferenceBundles/BLightAlertSettings.bundle/BLightAlertSettings
	@ldid -S //Library/PreferenceBundles/BLightAlertSettings.bundle/BLightAlertSettings
	@echo "DONE"
