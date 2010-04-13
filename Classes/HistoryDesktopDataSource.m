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

- (id) init
{
	self = [super init];
	if (self != nil) {
		data = [[HistoryData alloc] init];
	}
	return self;
}


- (NSInteger) numberOfItems {
	return [data count];
}

- (UIView *) viewAtIndex: (NSInteger)index {
	HoccerHistoryItem *historyItem = [data itemAtIndex:index];
	HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] 
							  createContentFromFile:[historyItem.filepath lastPathComponent] withMimeType:historyItem.mimeType];

	return [content desktopItemView];
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

- (void)removeView: (UIView *)view {
	
}

@end
