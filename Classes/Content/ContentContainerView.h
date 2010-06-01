//
//  ContentContainerView.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContentContainerViewDelegate.h";
@class Preview;

@interface ContentContainerView : UIView {
	id <ContentContainerViewDelegate> delegate;
	
	CGPoint touchStartPoint;
	BOOL gestureDetected;
	
	BOOL shouldSnapBackOnTouchUp;
	CGPoint origin;
	
	Preview *containedView;
	
	UIImageView *overlay;
	UIView *buttonContainer;	
}

@property (nonatomic, assign) id delegate;
@property (readonly) Preview* containedView;
@property (retain) UIView *buttonContainer;

@property (assign) CGPoint origin;

- (id) initWithView: (UIView *)subview actionButtons: (NSArray *)buttons;
- (void)moveBy: (CGSize)distance;

- (IBAction)toggleOverlay: (id)sender;
- (void)hideOverlay;
- (void)showSpinner;
- (void)hideSpinner;

@end