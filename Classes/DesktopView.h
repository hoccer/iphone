//
//  ReceiveViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DesktopViewDataSource.h"
#import "DesktopViewDelegate.h"
#import "ContentContainerViewDelegate.h"
#import "SweepInRecognizerDelegate.h"
#import "SweepOutRecognizerDelegate.h"

@class SweepRecognizer;

@interface DesktopView : UIView <ContentContainerViewDelegate, SweepInRecognizerDelegate, SweepOutRecognizerDelegate> {
	id <DesktopViewDelegate> delegate;
	id <DesktopViewDataSource> dataSource;

	NSMutableArray *sweepRecognizers;
	NSArray *currentlyTouchedViews;
	
	BOOL shouldSnapToCenterOnTouchUp;
}

@property (assign) id delegate;
@property (retain) id dataSource;
@property (retain) NSArray *currentlyTouchedViews;
@property (assign) BOOL shouldSnapToCenterOnTouchUp;

- (void)addSweepRecognizer: (SweepRecognizer *)recognizer;
- (void)reloadData;

- (void)animateView: (UIView *)view withAnimation: (CAAnimation *)animation;

@end
