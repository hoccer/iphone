//
//  ContentContainerView.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContentContainerView : UIView {
	id delegate;
	
	UIButton *button;
	
	CGPoint touchStartPoint;
	BOOL gestureDetected;
	
	BOOL shouldSnapBackOnTouchUp;
	CGPoint origin;
}

@property (nonatomic, retain) id delegate;
@property (assign) CGPoint origin;

- (id) initWithView: (UIView *)insideView;

- (void)resetViewAnimated: (BOOL)animated;
- (void)startFlySidewaysAnimation: (CGPoint) endPoint;
- (void)startFlyOutUpwardsAnimation;

@end
