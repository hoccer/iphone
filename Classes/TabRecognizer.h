//
//  TabRecognizer.h
//  Hoccer
//
//  Created by Robert Palmer on 27.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SweepRecognizer.h"
#import "TabRecognizerDelegate.h"

@class DesktopView;

@interface TabRecognizer : SweepRecognizer {
	NSTimer *touchUpTimer;
	NSInteger tabCount;
	
	UIView *tabedView;
	id <TabRecognizerDelegate> delegate;
}

@property (retain) NSTimer *touchUpTimer;
@property (retain) UIView *tabedView;
@property (assign) id <TabRecognizerDelegate> delegate;

- (void)desktopView: (DesktopView*)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
