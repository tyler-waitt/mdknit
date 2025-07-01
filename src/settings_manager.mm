#import "settings_manager.h"

NSString *const kSettingsChangedNotification = @"SettingsChangedNotification";
NSString *const kOutlinerModeKey = @"OutlinerMode";

@implementation SettingsManager

+ (instancetype)sharedManager {
    static SettingsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager loadSettings];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _outlinerMode = OutlinerModeCard;
    }
    return self;
}

- (void)setOutlinerMode:(OutlinerMode)outlinerMode {
    if (_outlinerMode != outlinerMode) {
        _outlinerMode = outlinerMode;
        [self saveSettings];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSettingsChangedNotification 
                                                            object:self
                                                          userInfo:@{kOutlinerModeKey: @(outlinerMode)}];
    }
}

- (void)saveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.outlinerMode forKey:kOutlinerModeKey];
    [defaults synchronize];
}

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kOutlinerModeKey]) {
        _outlinerMode = (OutlinerMode)[defaults integerForKey:kOutlinerModeKey];
    }
}

@end