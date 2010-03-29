//
//  DesktopDataSource.h
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DesktopDataSource : NSObject {
	NSMutableArray *contentOnDesktop;
}

- (NSInteger) numberOfItems;
- (UIViewController *)viewControllerAtIndex: (NSInteger) index;

- (void)addController: (UIViewController *)controller;
- (void)removeController: (UIViewController *)controller;

- (BOOL)controllerHasActiveRequest;

@end
