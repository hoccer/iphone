//
//  HistoryDesktopDataSource.m
//  Hoccer
//
//  Created by Robert Palmer on 13.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HistoryDesktopDataSource.h"
#import "Preview.h"
#import "HistoryData.h"
#import "HoccerHistoryItem.h";
#import "HoccerContent.h"
#import "HoccerContentFactory.h"

@implementation HistoryDesktopDataSource
@synthesize historyData;

- (id) init
{
	self = [super init];
	if (self != nil) {
		views = [[NSMutableArray alloc] init];
	}
	return self;
}



- (void) dealloc {
	[historyData release];
	[views release];
	
	[super dealloc];
}


- (NSInteger) numberOfItems {
	return [historyData count];
}

- (UIView *) viewAtIndex: (NSInteger)index {
	[views removeAllObjects];
	
	HoccerHistoryItem *historyItem = [historyData itemAtIndex:index];
	HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] 
							  createContentFromFile:[historyItem.filepath lastPathComponent] withMimeType:historyItem.mimeType];
	
	UIView *preview = [content desktopItemView];
	return preview;
}

- (CGPoint)positionForViewAtIndex: (NSInteger)index {
	static NSInteger rows = 2;
	static NSInteger cols = 2;
	
	NSInteger col = index / rows;
	NSInteger row = index % cols;
	
	return CGPointMake(col * 330 + 20, row * 220 + 20);
}

- (void)view: (UIView *)view didMoveToPoint: (CGPoint)point {
	
}

- (void)removeViewAtIndex: (NSInteger)index {
	[historyData removeItem: [historyData itemAtIndex:index]];
}


- (void)removeView: (UIView *)view {
	NSInteger index = [views indexOfObject:view];
	
	[historyData removeItem: [historyData itemAtIndex:index]];
	[views removeObjectAtIndex:index];
}

@end
