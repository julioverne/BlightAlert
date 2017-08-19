include theos/makefiles/common.mk

SUBPROJECTS += blightalerthook
SUBPROJECTS += blightalertsettings

include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	
