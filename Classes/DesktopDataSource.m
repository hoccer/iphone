//
//  DesktopDataSource.m
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DesktopDataSource.h"

#import "HocItemData.h"

@implementation DesktopDataSource
@synthesize viewController;

#pragma mark -
#pragma mark DesktopViewController Data Source

- (id) init {
	self = [super init];
	if (self != nil) {
		contentOnDesktop = [[NSMutableArray alloc] init];		
	}

	return self;
}

- (void) dealloc {
	[contentOnDesktop release];
	
	[super dealloc];
}

- (NSInteger) numberOfItems {
	return [contentOnDesktop count];
}

- (UIView *)viewAtIndex: (NSInteger)index {
	
	HocItemData *contentAtIndex = [contentOnDesktop objectAtIndex:index];
	return (UIView *) contentAtIndex.contentView; 	
}


- (void)addController: (HocItemData *)hocItem {
	[contentOnDesktop addObject:hocItem];
}

- (void)removeController: (HocItemData *)hocItem {
	[contentOnDesktop removeObject:hocItem];
}

- (BOOL)controllerHasActiveRequest {
	for (HocItemData *item in contentOnDesktop) {
		if ([item hasActiveRequest]) {
			return YES;
		}
	}
	
	return NO;
}

- (HocItemData *)hocItemDataForView: (UIView *)view {
	for (HocItemData *item in contentOnDesktop) {
		if ((UIView *)item.contentView == view) {
			return item;
		}
	}
	
	return nil;
}

- (HocItemData *)hocItemDataAtIndex: (NSInteger) index {
	return [contentOnDesktop objectAtIndex:index];
}

- (CGPoint) positionForViewAtIndex: (NSInteger)index {
	HocItemData *item = [self hocItemDataAtIndex:index];
	
	NSLog(@"item %@ in %f, %f", item, item.viewOrigin.x, item.viewOrigin.y);
	return [self hocItemDataAtIndex:index].viewOrigin;
}

- (void)view: (UIView *)view didMoveToPoint: (CGPoint)point {
	HocItemData *item = [self hocItemDataForView:view];
	NSLog(@"item %@ to %f, %f", item, point.x, point.y);
	item.viewOrigin = point;
}



@end
