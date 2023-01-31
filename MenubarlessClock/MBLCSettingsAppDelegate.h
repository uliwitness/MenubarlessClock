//
//  AppDelegate.h
//  MenubarlessClock
//
//  Created by Uli Kusterer on 23/05/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MBLCSettingsAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) BOOL		launchAtLogin;
@property (assign) BOOL		showBatteryLevel;
@property (assign) BOOL		showBatteryLevelOnlyWhenLow;
@property (assign) BOOL		showBatteryLevelOnlyWhenCharging;
@property (assign) BOOL		flashSeparators;

@end

