//
//  DesktopDataSource.h
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DesktopViewDataSource.h"

@class DragAndDropViewController;
@class HoccerController;

@interface DesktopDataSource : NSObject <DesktopViewDataSource, NSCoding> {
	NSMutableArray *contentOnDesktop;
	
	UIViewController *viewController;
}

@property (assign) UIViewController *viewController;

- (NSInteger) numberOfItems;
- (UIView *)viewAtIndex: (NSInteger) index;

- (void)addhoccerController: (HoccerController *)controller;
- (void)removehoccerController: (HoccerController *)controller;

- (BOOL)hasActiveRequest;

- (HoccerController *)hoccerControllerDataForView: (UIView *)controller;
- (HoccerController *)hoccerControllerDataAtIndex: (NSInteger) index;

- (NSInteger) count;

@end
