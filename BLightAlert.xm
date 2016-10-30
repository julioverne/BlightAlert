#import "BLightAlert.h"

static BOOL Enabled;
static BOOL AllAlerts;
static BOOL UseLed;
static BOOL doNotDisturbEnabled;
static BOOL DoNotDisturb;
static BOOL MinCurrent;
static BOOL MaxCurrent;
static __strong NSDictionary* PrefsDoc;
static int Speed;
static float Durations;
static float MinBrightness;
static float MaxBrightness;
static float RangeBrightness;

static BOOL isInAction;
static float oldBlacklightLevel;
static BOOL stopAlert;

static dispatch_queue_t Queue;
static SBCCBrightnessSectionController* SBBLClass;
static AVFlashlight *flashlight;

@interface BLightAlert : NSObject
+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
- (void)setBacklightLevel:(float)val;
- (void)startAlert;
@end

@implementation BLightAlert
__strong static id _sharedObject;
+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
		Queue = dispatch_queue_create("com.julioverne.blightalert", NULL);
		if ([AVFlashlight hasFlashlight]) {
			flashlight = [AVFlashlight new];
		}
	}
	return _sharedObject;
}
+ (BOOL)sharedInstanceExist
{
	if(_sharedObject) {
		return YES;
	}
	return NO;
}
- (void)setBacklightLevel:(float)val
{
	if(SBBLClass) {
		[SBBLClass _setBacklightLevel:val+0.001f];
		if(UseLed&&flashlight) {
			[flashlight setFlashlightLevel:val+0.001f withError:nil];
		}
		usleep(Speed);
	}
}
- (void)_startAlert
{
	if(YES) {
		dispatch_async(Queue, ^{
			isInAction = YES;
			int counte = 1;
			float blev = oldBlacklightLevel+0.001f;
			BOOL dec = NO;
			while(counte < Durations) {
				if(stopAlert) {
					stopAlert = NO;
					break;
				}
				if(blev > (MaxCurrent?(oldBlacklightLevel):(MaxBrightness))) {
					dec = YES;
				} else if(blev < (MinCurrent?(oldBlacklightLevel):(MinBrightness))) {
					dec = NO;
				}
				if (dec) {
					blev -= RangeBrightness;
				} else {
					blev += RangeBrightness;
				}
				[self setBacklightLevel:blev];
				counte++;
			}
			if(blev < oldBlacklightLevel) {
				while(blev < oldBlacklightLevel) {
					blev += RangeBrightness;
					[self setBacklightLevel:blev];
				}
			} else if(blev > oldBlacklightLevel) {
				while(blev > oldBlacklightLevel) {
					blev -= RangeBrightness;
					[self setBacklightLevel:blev];
				}
			}			
			[self setBacklightLevel:oldBlacklightLevel];
			if(UseLed&&flashlight) {
				[flashlight turnPowerOff];
			}			
			isInAction = NO;
		});
	}
}
- (void)stopAlert
{
	stopAlert = isInAction;	
}
- (void)startAlert
{
	if(isInAction) {
		return;
	}
	if(SBBLClass) {
		oldBlacklightLevel = [SBBLClass _backlightLevel];
	}
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_startAlert) object:self];
	[self performSelector:@selector(_startAlert) withObject:self afterDelay:0.3];
}
@end

static void AlertNotify()
{
	[[BLightAlert sharedInstance] startAlert];
}

%hook SBCCBrightnessSectionController
-(id)init
{
	id ret = %orig;
	SBBLClass = ret;
	if(!isInAction) {
		oldBlacklightLevel = [self _backlightLevel];
	}
	return ret;
}
- (void)_setBacklightLevel:(float)val
{
	if(!isInAction) {
		oldBlacklightLevel = val;
	}
	%orig;
}
%end
%hook SBCCDoNotDisturbSetting
-(void)_setDNDEnabled:(BOOL)arg1 updateServer:(BOOL)arg2 source:(unsigned long long)arg3
{
	doNotDisturbEnabled = arg1;
	%orig(arg1, arg2, arg3);
}
%end
%hook BBServer
- (void)_publishBulletinRequest:(id)request forSectionID:(NSString *)sectionID forDestinations:(unsigned long long)destination alwaysToLockScreen:(BOOL)onLockscreen
{
	%orig(request, sectionID, destination, onLockscreen);
	if (Enabled && !(DoNotDisturb && doNotDisturbEnabled) ) {
		if (AllAlerts) {
			notify_post(kAlertNotify);
		} else if (sectionID && [[PrefsDoc objectForKey:sectionID]?:@NO boolValue]) {
			notify_post(kAlertNotify);
		}
	}
}
%end

static void LoadPreferences()
{
	PrefsDoc = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
	Enabled = (BOOL)[[PrefsDoc objectForKey:@"Enabled"]?:@YES boolValue];
	AllAlerts = (BOOL)[[PrefsDoc objectForKey:@"AllAlerts"]?:@YES boolValue];
	DoNotDisturb = (BOOL)[[PrefsDoc objectForKey:@"DoNotDisturb"]?:@NO boolValue];
	MinCurrent = (BOOL)[[PrefsDoc objectForKey:@"MinCurrent"]?:@YES boolValue];
	MaxCurrent = (BOOL)[[PrefsDoc objectForKey:@"MaxCurrent"]?:@NO boolValue];
	UseLed = (BOOL)[[PrefsDoc objectForKey:@"UseLed"]?:@NO boolValue];
	Speed = (int)[[PrefsDoc objectForKey:@"Speed.0"]?:@(0.0) intValue];
	Durations = (float)[[PrefsDoc objectForKey:@"Duration.0"]?:@(3000) floatValue];
	MinBrightness = (float)[[PrefsDoc objectForKey:@"MinBrightness"]?:@(0.0) floatValue];
	MaxBrightness = (float)[[PrefsDoc objectForKey:@"MaxBrightness"]?:@(1.0) floatValue];
	RangeBrightness = (float)[[PrefsDoc objectForKey:@"RangeBrightness"]?:@(1) floatValue] / 1000;
	if([BLightAlert sharedInstanceExist]) {
		[[BLightAlert sharedInstance] stopAlert];
	}
}

#import <libactivator/libactivator.h>
@interface BLightAlertActivator : NSObject
+ (id)sharedInstance;
- (void)RegisterActions;
@end

@implementation BLightAlertActivator
+ (id)sharedInstance
{
    __strong static id _sharedObject;
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
	}
	return _sharedObject;
}
- (void)RegisterActions
{
    if (access("/usr/lib/libactivator.dylib", F_OK) == 0) {
		dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	    if (Class la = objc_getClass("LAActivator")) {
			[[la sharedInstance] registerListener:(id<LAListener>)self forName:@"com.julioverne.blightalert"];
		}
	}
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
	return @"BLightAlert";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
	return @"Make BLightAlert Start";
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/BLightAlertSettings.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/BLightAlertSettings.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if (Enabled && !(DoNotDisturb && doNotDisturbEnabled) ) {
		notify_post(kAlertNotify);
	}
}
@end

%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)AlertNotify, (CFStringRef)@kAlertNotify, NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)LoadPreferences, (CFStringRef)@kPreferenceChangedNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
	LoadPreferences();
	%init;
	[[BLightAlertActivator sharedInstance] RegisterActions];
}