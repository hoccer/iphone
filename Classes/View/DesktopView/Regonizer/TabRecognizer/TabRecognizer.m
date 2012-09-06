//
//  TabRecognizer.m
//  Hoccer
//
//  Created by Robert Palmer on 27.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "TabRecognizer.h"
#import "DesktopView.h"

@implementation TabRecognizer
@synthesize touchUpTimer;
@synthesize tabedView;
@synthesize delegate;

- (void)desktopView: (DesktopView*)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (tabCount > 0) {
		self.tabedView = [view.currentlyTouchedViews lastObject];

		[touchUpTimer invalidate];
		self.touchUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dispatchTabs) userInfo:nil repeats:NO];
	}
}

- (void)desktopView: (DesktopView*)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchUpTimer invalidate];	
	self.touchUpTimer = nil;
}

- (void)desktopView: (DesktopView*)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchUpTimer invalidate];
	self.touchUpTimer = nil;
	
	tabCount = 0;
}

- (void)desktopView: (DesktopView*)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchUpTimer invalidate];
	self.touchUpTimer = nil;
	
	tabCount++;
}

- (void)dispatchTabs {
	if ([delegate respondsToSelector:@selector(tabRecognizer:didDetectTabs:)]) {
		[delegate tabRecognizer:self didDetectTabs: tabCount];
	}
		
	self.touchUpTimer = nil;
	tabCount = 0;
	self.tabedView = nil;
}

- (void) dealloc {
	self.touchUpTimer = nil;
	[super dealloc];
}


@end
