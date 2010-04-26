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
@class HoccerConnectionController;

@interface DesktopDataSource : NSObject <DesktopViewDataSource, NSCoding> {
	NSMutableArray *contentOnDesktop;
	
	UIViewController *viewController;
}

@property (assign) UIViewController *viewController;

- (NSInteger) numberOfItems;
- (UIView *)viewAtIndex: (NSInteger) index;

- (void)addHocItem: (HoccerConnectionController *)controller;
- (void)removeHocItem: (HoccerConnectionController *)controller;

- (BOOL)hasActiveRequest;

- (HoccerConnectionController *)hocItemDataForView: (UIView *)controller;
- (HoccerConnectionController *)hocItemDataAtIndex: (NSInteger) index;

- (NSInteger) count;

@end
