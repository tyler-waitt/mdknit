#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OutlinerMode) {
    OutlinerModeCard = 0,
    OutlinerModeTree = 1
};

extern NSString *const kSettingsChangedNotification;
extern NSString *const kOutlinerModeKey;

@interface SettingsManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign) OutlinerMode outlinerMode;

- (void)saveSettings;
- (void)loadSettings;

@end

#endif