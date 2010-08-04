//
//  DesktopDataSource.m
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DesktopDataSource.h"

#import "HoccerController.h"
#import "HoccerContent.h"
#import "ContentContainerView.h"

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

- (void)addhoccerController: (HoccerController *)hoccerController {
	[contentOnDesktop addObject:hoccerController];
}

- (void)removeHoccerController: (HoccerController *)hoccerController {
	[contentOnDesktop removeObject:hoccerController];
}

- (BOOL)hasActiveRequest {
	for (HoccerController *item in contentOnDesktop) {
		if ([item hasActiveRequest]) {
			return YES;
		}
	}
	
	return NO;
}

- (HoccerController *)hoccerControllerDataForView: (UIView *)view {
	for (HoccerController *item in contentOnDesktop) {
		if ((UIView *)item.contentView == view) {
			return item;
		}
	}
	
	return nil;
}

- (HoccerController *)hoccerControllerDataAtIndex: (NSInteger) index {
	return [contentOnDesktop objectAtIndex:index];
}

#pragma mark -
#pragma mark DataSource Methods

- (NSInteger) numberOfItems {
	return [contentOnDesktop count];
}

- (UIView *)viewAtIndex: (NSInteger)index {
	HoccerController *contentAtIndex = [contentOnDesktop objectAtIndex:index];

	return (UIView *) contentAtIndex.contentView; 	
}

- (CGPoint)positionForViewAtIndex: (NSInteger)index {
	return [self hoccerControllerDataAtIndex:index].viewOrigin;
}

- (CGPoint)positionForView: (UIView *)view {
	return [self hoccerControllerDataForView:view].viewOrigin;
}

- (void)view: (UIView *)view didMoveToPoint: (CGPoint)point {
	HoccerController *item = [self hoccerControllerDataForView:view];
	item.viewOrigin = point;
}

- (void)removeView: (UIView *)view {
	HoccerController *item = [self hoccerControllerDataForView:view];
	
	[self removeHoccerController:item];
}

- (NSInteger) count {
	return [contentOnDesktop count];
}








@end
