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
@class HocItemData;

@interface DesktopDataSource : NSObject <DesktopViewDataSource, NSCoding> {
	NSMutableArray *contentOnDesktop;
	
	UIViewController *viewController;
}

@property (assign) UIViewController *viewController;

- (NSInteger) numberOfItems;
- (UIView *)viewAtIndex: (NSInteger) index;

- (void)addHocItem: (HocItemData *)controller;
- (void)removeHocItem: (HocItemData *)controller;

- (BOOL)controllerHasActiveRequest;

- (HocItemData *)hocItemDataForView: (UIView *)controller;
- (HocItemData *)hocItemDataAtIndex: (NSInteger) index;

@end
