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
	UIButton *button;
	
	CGPoint touchStartPoint;
	BOOL gestureDetected;
	
	BOOL shouldSnapBackOnTouchUp;
	CGPoint origin;
	
	UIView *containedView;
}

@property (nonatomic, assign) id delegate;
@property (readonly) UIView* containedView;

@property (assign) CGPoint origin;

- (id) initWithView: (UIView *)insideView;
- (void)moveBy: (CGSize)distance;

@end
