#include <stdio.h>
#include <stdlib.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#include <sys/sysctl.h>
#import <substrate.h>
#import <CommonCrypto/CommonCrypto.h>
#import <MediaPlayer/MediaPlayer.h>
#import <notify.h>

#define kAlertNotify "com.julioverne.blightalert"
#define kPreferenceChangedNotification "com.julioverne.blightalert/Settings"
#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.blightalert.plist"

@interface SBCCBrightnessSectionController : NSObject
- (void)_setBacklightLevel:(float)leve;
- (float)_backlightLevel;
@end

@interface AVFlashlight : NSObject
@property (getter=isAvailable, nonatomic, readonly) bool available;
@property (nonatomic, readonly) float flashlightLevel;
@property (getter=isOverheated, nonatomic, readonly) bool overheated;
+ (bool)hasFlashlight;
+ (void)initialize;
- (void)_handleNotification:(id)arg1 payload:(id)arg2;
- (void)_setupFlashlight;
- (void)_teardownFlashlight;
- (float)flashlightLevel;
- (bool)isAvailable;
- (bool)isOverheated;
- (bool)setFlashlightLevel:(float)arg1 withError:(id*)arg2;
- (void)turnPowerOff;
- (bool)turnPowerOnWithError:(id*)arg1;
@end

