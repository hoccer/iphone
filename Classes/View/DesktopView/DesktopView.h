//
//  ReceiveViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DesktopViewDataSource.h"
#import "DesktopViewDelegate.h"
#import "ContentContainerViewDelegate.h"
#import "SweepInRecognizerDelegate.h"
#import "SweepOutRecognizerDelegate.h"
#import "TabRecognizerDelegate.h"

//#define kSweepInBorder 50
//#define kSweepAcceptanceDistance 20
//#define kSweepOutBorder 30
//
//#define kSweepDirectionLeftIn -1
//#define kNoSweeping 0
//#define kSweepDirectionRightIn 1
//
//#define kSweepDirectionLeftOut -1
//#define kSweepDirectionRightOut 1


//#define kSweepBorder 50


typedef enum {
	HCDesktopBackgroundStylePerforated,
	HCDesktopBackgroundStyleLock
} HCDesktopBackgroundStyle;


@class SweepRecognizer;

@interface DesktopView : UIView <ContentContainerViewDelegate, SweepInRecognizerDelegate, SweepOutRecognizerDelegate, TabRecognizerDelegate> {
	id <DesktopViewDelegate> delegate;
	id <DesktopViewDataSource> dataSource;

	NSMutableArray *sweepRecognizers;
	NSMutableArray *volatileView;
	NSArray *currentlyTouchedViews;
	
	BOOL shouldSnapToCenterOnTouchUp;
	BOOL sweepIn;
}

@property (assign) id delegate;
@property (retain) id dataSource;
@property (retain) NSArray *currentlyTouchedViews;
@property (assign) BOOL shouldSnapToCenterOnTouchUp;
@property (nonatomic, assign) HCDesktopBackgroundStyle backgroundStyle;

- (void)addSweepRecognizer: (SweepRecognizer *)recognizer;
- (void)reloadData;

- (void)animateView: (UIView *)view withAnimation: (CAAnimation *)animation;
- (void)insertView: (UIView *)view atPoint:(CGPoint)point withAnimation: (CAAnimation *)animation;
- (void)removeView: (UIView *)view withAnimation: (CAAnimation *)animation;


@end
