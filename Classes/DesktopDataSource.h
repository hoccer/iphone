//
//  DesktopDataSource.h
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DragAndDropViewController;
@class HocItemData;

@interface DesktopDataSource : NSObject {
	NSMutableArray *contentOnDesktop;
}

- (NSInteger) numberOfItems;
- (DragAndDropViewController *)viewControllerAtIndex: (NSInteger) index;

- (void)addController: (HocItemData *)controller;
- (void)removeController: (HocItemData *)controller;

- (BOOL)controllerHasActiveRequest;

- (HocItemData *)hocItemDataForController: (DragAndDropViewController *)controller;
- (HocItemData *)hocItemDataAtIndex: (NSInteger) index;

@end
