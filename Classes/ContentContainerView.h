//
//  ContentContainerView.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContentContainerViewDelegate.h";

@interface ContentContainerView : UIView {
	id <ContentContainerViewDelegate> delegate;
	
	CGPoint touchStartPoint;
	BOOL gestureDetected;
	
	BOOL shouldSnapBackOnTouchUp;
	CGPoint origin;
	
	UIView *containedView;
	
	UIImageView *overlay;
	
}

@property (nonatomic, assign) id delegate;
@property (readonly) UIView* containedView;

@property (assign) CGPoint origin;

- (id) initWithView: (UIView *)subview actionButtons: (NSArray *)buttons;
- (void)moveBy: (CGSize)distance;

- (IBAction)toggleOverlay: (id)sender;

@end
