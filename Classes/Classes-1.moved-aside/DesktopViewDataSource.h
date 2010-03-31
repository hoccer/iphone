//
//  DesktopViewDataSource.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DragAndDropViewController;

@protocol DesktopViewDataSource

- (NSInteger) numberOfItems;
- (DragAndDropViewController *)viewControllerAtIndex: (NSInteger)index;


@end
