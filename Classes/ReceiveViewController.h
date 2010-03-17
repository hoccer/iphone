//
//  ReceiveViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReceiveViewController : UIViewController {
	id delegate;
	UIView* feedback;
	
	int sweeping;
	CGPoint initialTouchPoint;
}

@property (assign) id delegate;
@property (retain) UIView* feedback; 

- (void)startMoveToCenterAnimation;
- (void)startMoveOutAnimation: (NSInteger)direction;

-  (void)resetView;

@end
