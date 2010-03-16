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
	UIView* feeback;
	
	int sweeping;
	CGPoint initialTouchPoint;
}

@property (retain) UIView* feedback; 
@property (assign) id delegate;

- (void)startMoveToCenterAnimation;
- (void)startMoveOutAnimation: (NSInteger)direction;

@end
