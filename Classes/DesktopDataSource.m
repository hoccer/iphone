//
//  DesktopDataSource.m
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DesktopDataSource.h"

#import "HoccerConnectionController.h"
#import "HoccerContent.h"
#import "Preview.h"

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

#pragma mark NSCoding Delegate Methods
- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self != nil) {
		contentOnDesktop = [[decoder decodeObjectForKey:@"desktopContent"] retain];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:contentOnDesktop forKey:@"desktopContent"];	
}



- (void)addHocItem: (HoccerConnectionController *)hocItem {
	[contentOnDesktop addObject:hocItem];
}

- (void)removeHocItem: (HoccerConnectionController *)hocItem {
	[contentOnDesktop removeObject:hocItem];
}

- (BOOL)hasActiveRequest {
	for (HoccerConnectionController *item in contentOnDesktop) {
		if ([item hasActiveRequest]) {
			return YES;
		}
	}
	
	return NO;
}

- (HoccerConnectionController *)hocItemDataForView: (UIView *)view {
	for (HoccerConnectionController *item in contentOnDesktop) {
		if ((UIView *)item.contentView == view) {
			return item;
		}
	}
	
	return nil;
}

- (HoccerConnectionController *)hocItemDataAtIndex: (NSInteger) index {
	return [contentOnDesktop objectAtIndex:index];
}

#pragma mark -
#pragma mark DataSource Methods

- (NSInteger) numberOfItems {
	return [contentOnDesktop count];
}

- (UIView *)viewAtIndex: (NSInteger)index {
	HoccerConnectionController *contentAtIndex = [contentOnDesktop objectAtIndex:index];
	[contentAtIndex.content decorateViewWithGestureRecognition:contentAtIndex.contentView inViewController:self.viewController];

	return (UIView *) contentAtIndex.contentView; 	
}

- (CGPoint)positionForViewAtIndex: (NSInteger)index {
	return [self hocItemDataAtIndex:index].viewOrigin;
}

- (CGPoint)positionForView: (UIView *)view {
	return [self hocItemDataForView:view].viewOrigin;
}


- (void)view: (UIView *)view didMoveToPoint: (CGPoint)point {
	HoccerConnectionController *item = [self hocItemDataForView:view];
	item.viewOrigin = point;
}

- (void)removeView: (UIView *)view {
	HoccerConnectionController *item = [self hocItemDataForView:view];
	
	[self removeHocItem:item];
}

- (NSInteger) count {
	return [contentOnDesktop count];
}








@end
