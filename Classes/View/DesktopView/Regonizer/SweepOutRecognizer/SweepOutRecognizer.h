//
//  SweepOutRecognizer.h
//  Hoccer
//
//  Created by Robert Palmer on 08.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SweepRecognizer.h"
#import "SweepOutRecognizerDelegate.h"

//#define kSweepDirectionLeftOut -1
//#define kNoSweeping 0
//#define kSweepDirectionRightOut 1

@interface SweepOutRecognizer : SweepRecognizer {
	BOOL detecting;
	BOOL gestureDetected;
	NSInteger sweepDirection;
	
	UITouch *lastTouch;
	id <SweepOutRecognizerDelegate> delegate;
}

@property (nonatomic, assign) id <SweepOutRecognizerDelegate> delegate;

@property (assign) NSInteger sweepDirection;
@property (nonatomic, retain) UITouch *lastTouch;


- (void)desktopView: (DesktopView*)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
