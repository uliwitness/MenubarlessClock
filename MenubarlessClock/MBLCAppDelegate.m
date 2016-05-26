//
//  MBLCAppDelegate.m
//  MenubarlessClock
//
//  Created by Uli Kusterer on 21/05/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "MBLCAppDelegate.h"
#import <IOKit/ps/IOPowerSources.h>


@interface MBLCContentView : NSView

@property (strong) NSTrackingArea*		trackingArea;

@end

@implementation MBLCContentView

-(void)	drawRect:(NSRect)dirtyRect
{
	[[NSColor clearColor] set];
	NSRectFill(self.bounds);
	
	[self.window.backgroundColor set];
	CGFloat		cornerRadius = 6;
	NSRect		bezelBox = self.bounds;
	bezelBox.size.height += cornerRadius;
	bezelBox.size.width += cornerRadius;
	[[NSBezierPath bezierPathWithRoundedRect: bezelBox xRadius: cornerRadius yRadius: cornerRadius] fill];
}


-(void)	updateTrackingAreas
{
	[super updateTrackingAreas];
	
	if( self.trackingArea )
		[self removeTrackingArea: self.trackingArea];
	self.trackingArea = [[NSTrackingArea alloc] initWithRect: self.bounds options: NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner: self userInfo: nil];
	[self addTrackingArea: self.trackingArea];
}


-(void)	mouseEntered: (NSEvent *)theEvent
{
	[self.window.animator setAlphaValue: 0.0];
}


-(void)	mouseExited: (NSEvent *)theEvent
{
	[self.window.animator setAlphaValue: 1.0];
}

@end


@interface MBLCAppDelegate ()

@property (weak) IBOutlet NSWindow *	window;
@property (weak) IBOutlet NSTextField *	timeField;
@property (assign) BOOL					showSeconds;
@property (assign) BOOL					showBatteryLevel;
@property (assign) BOOL					showBatteryLevelOnlyWhenLow;

@end

@implementation MBLCAppDelegate

- (void)	applicationDidFinishLaunching: (NSNotification *)aNotification
{
	NSUserDefaults*	ud = [[NSUserDefaults alloc] initWithSuiteName: @"com.thevoidsoftware.MenubarlessClock"];
	[ud registerDefaults: [NSDictionary dictionaryWithContentsOfURL: [NSBundle.mainBundle URLForResource: @"InitialDefaults" withExtension: @"plist"]]];
	self.showSeconds = [ud boolForKey: @"MBLCShowSeconds"];
	self.showBatteryLevel = [ud boolForKey: @"MBLCShowBatteryLevel"];
	self.showBatteryLevelOnlyWhenLow = [ud boolForKey: @"MBLCShowBatteryLevelOnlyWhenLow"];
	
	self.window.alphaValue = 0.0;
	NSTimer*	clockTimer = [NSTimer scheduledTimerWithTimeInterval: self.showSeconds ? 1.0 : 60.0 target: self selector: @selector(updateClock:) userInfo: nil repeats: YES];
	[clockTimer setFireDate: [NSDate date]];
	self.window.level = NSMainMenuWindowLevel;
	self.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
	self.window.opaque = NO;
	[self.window orderFront: self];
	self.window.animator.alphaValue = 1.0;
	self.window.movable = NO;
	
	if ([NSFont.class respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)])
	{
		NSFont *monospaceFont = [NSFont monospacedDigitSystemFontOfSize: 14.0 weight: NSFontWeightMedium];
		self.timeField.font = monospaceFont;
	}
	
	[NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(adaptUIToDarkMode) name:@"AppleInterfaceThemeChangedNotification" object:nil];
	[self adaptUIToDarkMode];
}


#define BATT_FRAME_PATH		@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/BatteryEmpty.pdf"
#define BATT_CAP_L_PATH		@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/BatteryLevelCapB-L.pdf"
#define BATT_CAP_M_PATH		@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/BatteryLevelCapB-M.pdf"
#define BATT_CAP_R_PATH		@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/BatteryLevelCapB-R.pdf"
#define BATT_RED_L_PATH		@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/BatteryLevelCapR-L.pdf"
#define BATT_RED_M_PATH		@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/BatteryLevelCapR-M.pdf"
#define BATT_RED_R_PATH		@"/System/Library/CoreServices/Menu Extras/Battery.menu/Contents/Resources/BatteryLevelCapR-R.pdf"


-(NSImage*)	batteryImageForLevel: (double)batteryFraction
{
	/*
		DISCLAIMER: It is bad style to just reference arbitrary images in a system folder. Apple may,
		at any time, change the metrics or even the names of these image files, split them up differently
		etc. Why am I doing it, then? Because I'm too lazy to draw my own, and this is a tool for my
		personal use, and I'm not being paid for this. Pull requests with image donations gladly accepted.
		(Remember: We can't copy Apple's graphics, they own the Copyright, don't submit them!)
	*/
	
	NSImage*		batteryImage = [[NSImage alloc] initWithContentsOfFile: BATT_FRAME_PATH];
	return [NSImage imageWithSize: batteryImage.size flipped: NO drawingHandler: ^BOOL(NSRect dstRect)
	{
		BOOL			levelLow = batteryFraction <= 0.2;
		NSImage*		leftCap = [[NSImage alloc] initWithContentsOfFile: levelLow ? BATT_RED_L_PATH : BATT_CAP_L_PATH];
		NSImage*		middle = [[NSImage alloc] initWithContentsOfFile: levelLow ? BATT_RED_M_PATH : BATT_CAP_M_PATH];
		NSImage*		rightCap = [[NSImage alloc] initWithContentsOfFile: levelLow ? BATT_RED_R_PATH : BATT_CAP_R_PATH];
		
		// Calculate rectangles for the various parts:
		NSRect	batteryBox = { NSZeroPoint, batteryImage.size };
		NSRect	leftCapBox = NSZeroRect, midBox = NSZeroRect, rightCapBox = NSZeroRect;
		leftCapBox.size.height = middle.size.height;
		leftCapBox.origin.y = trunc((batteryBox.size.height -leftCapBox.size.height) / 2.0);
		leftCapBox.origin.x += 2;
		leftCapBox.size.width = leftCap.size.width;
		
		rightCapBox = leftCapBox;
		rightCapBox.origin.x = batteryBox.size.width -rightCapBox.size.width - 5;
		
		midBox = leftCapBox;
		midBox.origin.x = NSMaxX(leftCapBox);
		midBox.size.width = NSMinX(rightCapBox) -midBox.origin.x;

		NSRect	capArea = leftCapBox;
		capArea.size.width = (NSMaxX(rightCapBox) -capArea.origin.x) * batteryFraction;
		
		// Draw!
		[batteryImage drawAtPoint: NSZeroPoint fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];

		[NSBezierPath clipRect: capArea];	// Make sure level capsule only occupies area corresponding to level.
		
		[leftCap drawAtPoint: leftCapBox.origin fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
		[middle drawInRect: midBox fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
		[rightCap drawAtPoint: rightCapBox.origin fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
		return YES;
	}];
}


-(void)		appendBatteryStateTo: (NSMutableAttributedString*)currInfoString
{
	CFTypeRef			psInfo = IOPSCopyPowerSourcesInfo();
	NSArray*			powerSources = (__bridge NSArray *)(IOPSCopyPowerSourcesList(psInfo));
	for( id currSource in powerSources )
	{
		NSDictionary* dict = (__bridge NSDictionary *)(IOPSGetPowerSourceDescription( psInfo, (__bridge CFTypeRef)(currSource) ));
		if( [dict[@"Type"] isEqualToString: @"InternalBattery"] )
		{
			double	batteryFraction = [dict[@"Current Capacity"] doubleValue] / [dict[@"Max Capacity"] doubleValue];
			int	batteryPercentage = batteryFraction * 100.0;
			if( !self.showBatteryLevelOnlyWhenLow || batteryPercentage < 20 )
			{
				NSTextAttachment*		att = [NSTextAttachment new];
				NSTextAttachmentCell*	attCell = [NSTextAttachmentCell new];
				attCell.image = [self batteryImageForLevel: batteryFraction];
				att.attachmentCell = attCell;
//				[self appendString: [NSString stringWithFormat: @"%d %% ", batteryPercentage] toAttributedString: currInfoString];
				[currInfoString appendAttributedString: [NSAttributedString attributedStringWithAttachment: att]];
				[self appendString: [NSString stringWithFormat: @"  "] toAttributedString: currInfoString];
			}
			break;
		}
//		Example for battery dictionary contents:
//		{
//			"Battery Provides Time Remaining" = 1;
//			BatteryHealth = Good;
//			Current = 137;
//			"Current Capacity" = 100;
//			DesignCycleCount = 1000;
//			"Hardware Serial Number" = D8650920127FQM6B0;
//			"Is Charged" = 1;
//			"Is Charging" = 0;
//			"Is Present" = 1;
//			"Max Capacity" = 100;
//			Name = "InternalBattery-0";
//			"Power Source State" = "AC Power";
//			"Time to Empty" = 0;
//			"Time to Full Charge" = 0;
//			"Transport Type" = Internal;
//			Type = InternalBattery;
//		}
	}
}


-(void)	appendString: (NSString*)newStr toAttributedString: (NSMutableAttributedString*)attrStr
{
	NSAttributedString	*newAttrStr = [[NSAttributedString alloc] initWithString: newStr attributes: @{ NSFontAttributeName: self.timeField.font }];
	[attrStr appendAttributedString: newAttrStr];
}


- (void)	updateClock: (NSTimer*)sender
{
	static NSDateFormatter *	sTimeFormatter = nil;
	if( !sTimeFormatter )
	{
		sTimeFormatter = [[NSDateFormatter alloc] init];
		sTimeFormatter.formattingContext = NSFormattingContextStandalone;
		sTimeFormatter.dateStyle = NSDateFormatterNoStyle;
		sTimeFormatter.timeStyle = self.showSeconds ? NSDateFormatterMediumStyle : NSDateFormatterShortStyle;
	}
	
	NSMutableAttributedString	*	currInfoString = [NSMutableAttributedString new];
	
	if( self.showBatteryLevel )
		[self appendBatteryStateTo: currInfoString];
	
	NSDate			*	currentTime = [NSDate date];
	[self appendString: [sTimeFormatter stringFromDate: currentTime] toAttributedString: currInfoString];
	
	[self.timeField setAttributedStringValue: currInfoString];
	[self.window layoutIfNeeded];
	NSRect			currentBox = self.window.frame;
	NSScreen	*	theScreen = self.window.screen;
	if( !theScreen )
		theScreen = NSScreen.screens[0];
	NSRect			screenFrame = theScreen.frame;
	currentBox.origin.x = NSMaxX(screenFrame) -currentBox.size.width;
	currentBox.origin.y = NSMaxY(screenFrame) -currentBox.size.height;
	[self.window setFrame: currentBox display: YES];
	
	if( !self.showSeconds )
	{
		static NSCalendar	*	sGregorianCalendar = nil;
		if( !sGregorianCalendar )
		{
			sGregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
		}
		NSInteger	seconds = [sGregorianCalendar component: NSCalendarUnitSecond fromDate: currentTime];
		NSDate*		nextFullMinuteFireTime = [sGregorianCalendar dateByAddingUnit: NSCalendarUnitSecond value: 60.0 -seconds toDate: currentTime options: 0];
		[sender setFireDate: nextFullMinuteFireTime];
	}
}


- (BOOL)	darkModeEnabled
{
	NSDictionary *dict = [NSUserDefaults.standardUserDefaults persistentDomainForName:NSGlobalDomain];
	id style = [dict objectForKey:@"AppleInterfaceStyle"];
	return ( style && [style isKindOfClass:NSString.class] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"] );
}


- (void)	adaptUIToDarkMode
{
	if (self.darkModeEnabled)
	{
		self.window.backgroundColor = [NSColor colorWithWhite: 0.0 alpha: 0.7];
		self.timeField.textColor = [NSColor whiteColor];
	}
	else
	{
		self.window.backgroundColor = [NSColor colorWithWhite: 1.0 alpha: 0.9];
		self.timeField.textColor = [NSColor blackColor];
	}
}

@end
