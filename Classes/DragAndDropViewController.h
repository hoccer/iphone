//
//  PreviewViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragAndDropViewController : UIViewController {
	id delegate;
	CGPoint origin;
	
	CGPoint touchStartPoint;
	BOOL gestureDetected;
	
	BOOL shouldSnapBackOnTouchUp;
}

@property (nonatomic, retain) id delegate;
@property (assign) CGPoint origin;
@property (assign) BOOL shouldSnapBackOnTouchUp;

- (void)dismissKeyboard;
- (void)resetViewAnimated: (BOOL)animated;
- (void)startFlyOutUpwardsAnimation;
- (void)startFlySidewaysAnimation: (CGPoint) endPoint;

@end
