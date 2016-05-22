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


-(void)	setLaunchAtLogin: (BOOL)inState
{
	SMLoginItemSetEnabled( CFSTR(MBLC_HELPER_BUNDLE_ID), inState == YES );
	if( inState )
	{
		NSString	*	appPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString: @MBLC_HELPER_SUBPATH];
		[[NSWorkspace sharedWorkspace] launchApplication: appPath];
		[self.window makeKeyAndOrderFront: self];
	}
	else
	{
		NSArray	*	apps = [[NSWorkspace sharedWorkspace] runningApplications];
		for( NSRunningApplication * currApp in apps )
		{
			if( [[currApp bundleIdentifier] isEqualToString: @MBLC_HELPER_BUNDLE_ID] )
				[currApp terminate];
		}
	}
}


-(BOOL)	showSeconds
{
	return [[NSUserDefaults standardUserDefaults] boolForKey: @"MBLCShowSeconds"];
}


-(void)	setShowSeconds: (BOOL)inState
{
	BOOL		wasRunning = NO;
	NSArray	*	apps = [[NSWorkspace sharedWorkspace] runningApplications];
	for( NSRunningApplication * currApp in apps )
	{
		if( [[currApp bundleIdentifier] isEqualToString: @MBLC_HELPER_BUNDLE_ID] )
		{
			[currApp terminate];
			wasRunning = YES;
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setBool: inState forKey: @"MBLCShowSeconds"];
	
	if( wasRunning )
	{
		NSString	*	appPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString: @MBLC_HELPER_SUBPATH];
		[[NSWorkspace sharedWorkspace] launchApplication: appPath];
		[self.window makeKeyAndOrderFront: self];
	}
}

@end
