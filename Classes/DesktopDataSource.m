//
//  DesktopDataSource.m
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DesktopDataSource.h"
#import "DragAndDropViewController.h"
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

- (DragAndDropViewController *)viewControllerAtIndex: (NSInteger)index {
	
	DragAndDropViewController *dragdropViewController =  ((HocItemData *)[contentOnDesktop objectAtIndex:index]).dragAndDropViewConroller;
	[dragdropViewController.content decorateViewWithGestureRecognition:dragdropViewController.view inViewController: self.viewController];

	return dragdropViewController; 	
}


- (void)addController: (HocItemData *)hocItem {
	NSLog(@"controller: %@", hocItem.dragAndDropViewConroller);

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

- (HocItemData *)hocItemDataForController: (DragAndDropViewController *)controller {
	for (HocItemData *item in contentOnDesktop) {
		if (item.dragAndDropViewConroller == controller) {
			return item;
		}
	}
	
	return nil;
}

- (HocItemData *)hocItemDataAtIndex: (NSInteger) index {
	return [contentOnDesktop objectAtIndex:index];
}





@end
