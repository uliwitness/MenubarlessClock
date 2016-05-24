//
//  MBLCAppDelegate.m
//  MenubarlessClock
//
//  Created by Uli Kusterer on 21/05/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "MBLCAppDelegate.h"


@interface MBLCContentView : NSView

@property (strong) NSTrackingArea*		trackingArea;

@end

@implementation MBLCContentView

-(void)	drawRect:(NSRect)dirtyRect
{
	[[NSColor clearColor] set];
	NSRectFill(self.bounds);
	
	[[NSColor colorWithWhite: 0.0 alpha: 0.7] set];
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

@end

@implementation MBLCAppDelegate

- (void)	applicationDidFinishLaunching: (NSNotification *)aNotification {
	self.showSeconds = [[[NSUserDefaults alloc] initWithSuiteName: @"com.thevoidsoftware.MenubarlessClock"] boolForKey: @"MBLCShowSeconds"];
	
	self.window.alphaValue = 0.0;
	NSTimer*	clockTimer = [NSTimer scheduledTimerWithTimeInterval: self.showSeconds ? 1.0 : 60.0 target: self selector: @selector(updateClock:) userInfo: nil repeats: YES];
	[clockTimer setFireDate: [NSDate date]];
	self.window.level = NSMainMenuWindowLevel;
	self.window.opaque = NO;
	[self.window orderFront: self];
	self.window.animator.alphaValue = 1.0;
	self.window.movable = NO;
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
	NSDate		*	currentTime = [NSDate date];
	[self.timeField setStringValue: [sTimeFormatter stringFromDate: currentTime]];
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

@end
