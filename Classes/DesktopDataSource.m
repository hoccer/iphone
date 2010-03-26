//
//  DesktopDataSource.m
//  Hoccer
//
//  Created by Robert Palmer on 26.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DesktopDataSource.h"


@implementation DesktopDataSource

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

- (UIViewController *)viewControllerForItem: (NSInteger)itemNumber {
	
	return [contentOnDesktop objectAtIndex:itemNumber];
}

- (void)addController: (UIViewController *)controller {
	[contentOnDesktop addObject:controller];
}

- (void)removeController: (UIViewController *)controller {
	[contentOnDesktop removeObject:controller];
}




@end
