//
//  ReceiveViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DesktopViewController : UIViewController {
	id delegate;
	id dataSource;
	
	UIView* feedback;
	
	int sweeping;
	BOOL blocked;
	CGPoint initialTouchPoint;
	
	BOOL shouldSnapToCenterOnTouchUp;
}

@property (assign) id delegate;
@property (retain) id dataSource;

@property (retain) UIView* feedback; 
@property (assign) BOOL blocked;
@property (assign) BOOL shouldSnapToCenterOnTouchUp;

- (void)startMoveToCenterAnimation;
- (void)startMoveOutAnimation: (NSInteger)direction;

- (void)resetView;
- (void)reloadData;

@end
