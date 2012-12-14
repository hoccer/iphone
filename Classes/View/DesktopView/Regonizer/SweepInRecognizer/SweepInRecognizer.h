//
//  SweepInRecognizer.h
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SweepRecognizer.h"
#import "SweepInRecognizerDelegate.h"

//#define kSweepDirectionLeftIn -1
//#define kNoSweeping 0
//#define kSweepDirectionRightIn 1

@class DesktopView;

@interface SweepInRecognizer : SweepRecognizer {
	NSInteger sweepDirection;
	CGPoint touchPoint;
	
	id <SweepInRecognizerDelegate> delegate;
	BOOL isSweeping;
}

@property (nonatomic, readonly) NSInteger sweepDirection;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) id <SweepInRecognizerDelegate> delegate;


- (void)desktopView: (DesktopView*)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)desktopView: (DesktopView*)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
