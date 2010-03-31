//
//  DesktopDataSource.m
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DesktopDataSource.h"

#import "HocItemData.h"
#import "HoccerContent.h"

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

- (void)addHocItem: (HocItemData *)hocItem {
	[contentOnDesktop addObject:hocItem];
}

- (void)removeHocItem: (HocItemData *)hocItem {
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

#pragma mark -
#pragma mark DataSource Methods

- (NSInteger) numberOfItems {
	return [contentOnDesktop count];
}

- (UIView *)viewAtIndex: (NSInteger)index {
	HocItemData *contentAtIndex = [contentOnDesktop objectAtIndex:index];
	[contentAtIndex.content decorateViewWithGestureRecognition:contentAtIndex.contentView inViewController:self.viewController];

	return (UIView *) contentAtIndex.contentView; 	
}

- (CGPoint) positionForViewAtIndex: (NSInteger)index {
	return [self hocItemDataAtIndex:index].viewOrigin;
}

- (void)view: (UIView *)view didMoveToPoint: (CGPoint)point {
	HocItemData *item = [self hocItemDataForView:view];
	item.viewOrigin = point;
}

- (void)removeView: (UIView *)view {
	HocItemData *item = [self hocItemDataForView:view];
	[self removeHocItem:item];
}


@end
