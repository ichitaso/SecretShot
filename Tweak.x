#import <UIKit/UIKit.h>
#include <roothide.h>

#define NSLog(fmt, ...) NSLog((@"[SecretShot]" fmt), ##__VA_ARGS__)

// Preferences
#define PREF_PATH jbroot(@"/var/mobile/Library/Preferences/com.eamontracey.secretshotpreferences.plist")
#define Notify_Preferences "com.eamontracey.secretshotpreferences/saved"
static BOOL enabled;

%group Hooks

%hook NSNotificationCenter

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject {
    if (aName != UIApplicationUserDidTakeScreenshotNotification) {
        %orig;
    }
}

%end

%hook UIScreen

- (BOOL)isCaptured {
    return NO;
}

%end

%end // Hooks group end

static void loadPreferences(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    enabled = (BOOL)[dict[@"enabled"] ?: @YES boolValue];
}

%ctor {
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        loadPreferences,
                                        CFSTR(Notify_Preferences),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);

        loadPreferences(NULL, NULL, NULL, NULL, NULL);
        // Note: It must be written at the bottom or it will not work.
        // You need to kill the process every time you turn it on or off because Snapchat will detect the modification.
        if (enabled) %init(Hooks);
    }
}