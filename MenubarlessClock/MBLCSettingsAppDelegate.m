//
//  AppDelegate.m
//  MenubarlessClock
//
//  Created by Uli Kusterer on 23/05/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "MBLCSettingsAppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>


#define MBLC_HELPER_BUNDLE_ID		"com.thevoidsoftware.MenubarlessClock.helper"
#define MBLC_HELPER_SUBPATH			"/Contents/Library/LoginItems/MenubarlessClock Helper.app"


@interface MBLCSettingsAppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end


@implementation MBLCSettingsAppDelegate

-(void)	applicationDidFinishLaunching:(NSNotification *)notification
{
	[NSUserDefaults.standardUserDefaults registerDefaults: [NSDictionary dictionaryWithContentsOfURL: [NSBundle.mainBundle URLForResource: @"InitialDefaults" withExtension: @"plist"]]];
}


-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}


-(BOOL)	launchAtLogin
{
	NSArray	*	apps = [[NSWorkspace sharedWorkspace] runningApplications];
	for( NSRunningApplication * currApp in apps )
	{
		if( [[currApp bundleIdentifier] isEqualToString: @MBLC_HELPER_BUNDLE_ID] )
			return YES;
	}
	return NO;
}


-(NSRunningApplication*)	helperApplication
{
	NSArray	*	apps = [[NSWorkspace sharedWorkspace] runningApplications];
	for( NSRunningApplication * currApp in apps )
	{
		if( [[currApp bundleIdentifier] isEqualToString: @MBLC_HELPER_BUNDLE_ID] )
			return currApp;
	}
	
	return nil;
}


-(void)	setLaunchAtLogin: (BOOL)inState
{
	SMLoginItemSetEnabled( CFSTR(MBLC_HELPER_BUNDLE_ID), inState == YES );
	if( inState )
	{
		if( ![self helperApplication] )
		{
			NSString	*	appPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString: @MBLC_HELPER_SUBPATH];
			[[NSWorkspace sharedWorkspace] launchApplication: appPath];
			[self.window makeKeyAndOrderFront: self];
		}
	}
	else
	{
		[[self helperApplication] terminate];
	}
}


-(BOOL)	showSeconds
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: @"MBLCShowSeconds"];
}


-(void)	setShowSeconds: (BOOL)inState
{
	NSRunningApplication	*	theHelper = [self helperApplication];
	[theHelper terminate];
	
	[[NSUserDefaults standardUserDefaults] setBool: inState forKey: @"MBLCShowSeconds"];
	
	[self performSelector: @selector(ensureRelaunchWorked:) withObject: theHelper afterDelay: 1.0];
}


-(BOOL)	showBatteryLevel
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: @"MBLCShowBatteryLevel"];
}


-(void)	setShowBatteryLevel: (BOOL)inState
{
	NSRunningApplication	*	theHelper = [self helperApplication];
	[theHelper terminate];
	
	[[NSUserDefaults standardUserDefaults] setBool: inState forKey: @"MBLCShowBatteryLevel"];
	
	[self performSelector: @selector(ensureRelaunchWorked:) withObject: theHelper afterDelay: 1.0];
}


-(BOOL)	showBatteryLevelOnlyWhenLow
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: @"MBLCShowBatteryLevelOnlyWhenLow"];
}


-(void)	setShowBatteryLevelOnlyWhenLow: (BOOL)inState
{
	NSRunningApplication	*	theHelper = [self helperApplication];
	[theHelper terminate];
	
	[[NSUserDefaults standardUserDefaults] setBool: inState forKey: @"MBLCShowBatteryLevelOnlyWhenLow"];
	
	[self performSelector: @selector(ensureRelaunchWorked:) withObject: theHelper afterDelay: 1.0];
}


-(BOOL)	showBatteryLevelOnlyWhenCharging
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: @"MBLCShowBatteryLevelOnlyWhenCharging"];
}


-(void)	setShowBatteryLevelOnlyWhenCharging: (BOOL)inState
{
	NSRunningApplication	*	theHelper = [self helperApplication];
	[theHelper terminate];
	
	[[NSUserDefaults standardUserDefaults] setBool: inState forKey: @"MBLCShowBatteryLevelOnlyWhenCharging"];
	
	[self performSelector: @selector(ensureRelaunchWorked:) withObject: theHelper afterDelay: 1.0];
}


-(BOOL)	flashSeparators
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: @"MBLCFlashSeparators"];
}


-(void)	setFlashSeparators: (BOOL)inState
{
	NSRunningApplication	*	theHelper = [self helperApplication];
	[theHelper terminate];
	
	[[NSUserDefaults standardUserDefaults] setBool: inState forKey: @"MBLCFlashSeparators"];
	
	[self performSelector: @selector(ensureRelaunchWorked:) withObject: theHelper afterDelay: 1.0];
}


-(void)	ensureRelaunchWorked: (id)theHelper
{
	if( theHelper && ![self helperApplication] )	// Had a helper, don't have one now? Re-launch!
	{
		NSString	*	appPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString: @MBLC_HELPER_SUBPATH];
		[[NSWorkspace sharedWorkspace] launchApplication: appPath];
		[self.window makeKeyAndOrderFront: self];
	}
}

@end
