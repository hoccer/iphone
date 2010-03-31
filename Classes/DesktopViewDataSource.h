//
//  DesktopViewDataSource.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DesktopViewDataSource

- (NSInteger) numberOfItems;
- (UIView *) viewAtIndex: (NSInteger)index;
- (CGPoint) positionForViewAtIndex: (NSInteger)index;

- (void)view: (UIView *)view didMoveToPoint: (CGPoint)point;


@end
