//
//  DesktopDataSource.m
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "DesktopDataSource.h"

#import "ItemViewController.h"
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

#pragma mark -
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

- (void)notifyContentChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NumberOfDesktopItemsChanged" object:nil];
}

- (void)addhoccerController: (ItemViewController *)hoccerController {
	[contentOnDesktop addObject:hoccerController];
    [self notifyContentChange];
}

- (void)removeHoccerController: (ItemViewController *)hoccerController {
	[contentOnDesktop removeObject:hoccerController];
    [self notifyContentChange];
}

- (ItemViewController *)hoccerControllerDataForView: (UIView *)view {
	for (ItemViewController *item in contentOnDesktop) {
		if ((UIView *)item.contentView == view) {
			return item;
		}
	}
	
	return nil;
}

- (ItemViewController *)hoccerControllerDataAtIndex: (NSInteger) index
{
    if (contentOnDesktop != nil) {
        if ([contentOnDesktop count] >= index + 1) {
            return [contentOnDesktop objectAtIndex:index];
        }
    }
    return nil;
}

#pragma mark -
#pragma mark DataSource Methods

- (NSInteger)numberOfItems {
	return [contentOnDesktop count];
}

- (UIView *)viewAtIndex: (NSInteger)index {
	ItemViewController *contentAtIndex = [contentOnDesktop objectAtIndex:index];

	return (UIView *) contentAtIndex.contentView; 	
}

- (CGPoint)positionForViewAtIndex: (NSInteger)index {
	return [self hoccerControllerDataAtIndex:index].viewOrigin;
}

- (CGPoint)positionForView: (UIView *)view {
	return [self hoccerControllerDataForView:view].viewOrigin;
}

- (void)view: (UIView *)view didMoveToPoint:(CGPoint)point {
	ItemViewController *item = [self hoccerControllerDataForView:view];
	item.viewOrigin = point;
}

- (void)removeView: (UIView *)view
{
	ItemViewController *item = [self hoccerControllerDataForView:view];
	
	[self removeHoccerController:item];
}

- (NSInteger) count {
	return [contentOnDesktop count];
}








@end
