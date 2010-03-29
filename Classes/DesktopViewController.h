//
//  ReceiveViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DesktopViewDataSource.h"
@class DragAndDropViewController;

@interface DesktopViewController : UIViewController {
	id delegate;
	id <DesktopViewDataSource> dataSource;
	
	DragAndDropViewController* feedback;
	
	int sweeping;
	CGPoint initialTouchPoint;
	
	BOOL shouldSnapToCenterOnTouchUp;
}

@property (assign) id delegate;
@property (retain) id dataSource;

@property (retain) DragAndDropViewController* feedback; 
@property (assign) BOOL shouldSnapToCenterOnTouchUp;

- (void)startMoveToCenterAnimation;
- (void)startMoveOutAnimation: (NSInteger)direction;

- (void)resetView;
- (void)reloadData;

@end
