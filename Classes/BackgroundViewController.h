//
//  ReceiveViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BackgroundViewController : UIViewController {
	id delegate;
	UIView* feedback;
	
	int sweeping;
	BOOL blocked;
	CGPoint initialTouchPoint;
}

@property (assign) id delegate;
@property (retain) UIView* feedback; 
@property (assign) BOOL blocked;

- (void)startMoveToCenterAnimation;
- (void)startMoveOutAnimation: (NSInteger)direction;

-  (void)resetView;

@end
