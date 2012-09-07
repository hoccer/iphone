//
//  ContentContainerView.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContentContainerViewDelegate.h"
#import "MBProgressHUD.h"
@class Preview;

@interface ContentContainerView : UIView {
	id <ContentContainerViewDelegate> delegate;
	
	CGPoint touchStartPoint;
	BOOL gestureDetected;
	
	BOOL shouldSnapBackOnTouchUp;
	CGPoint origin;
	
	Preview *containedView;
	
	UIView *overlay;
	UIView *buttonContainer;	
}

@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) Preview* containedView;
@property (retain) UIView *buttonContainer;

@property (assign, nonatomic) CGPoint origin;

- (id) initWithView: (UIView *)subview actionButtons: (NSArray *)buttons;
- (void)moveBy: (CGSize)distance;

- (IBAction)toggleOverlay: (id)sender;
- (void)hideOverlay;
- (void)showSpinner;
- (void)hideSpinner;
- (void)showSuccess;
- (void)updateFrame;

@end
