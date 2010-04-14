//
//  HistoryDesktopDataSource.h
//  Hoccer
//
//  Created by Robert Palmer on 13.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DesktopViewDataSource.h"

@class HistoryData;

@interface HistoryDesktopDataSource : NSObject <DesktopViewDataSource> {

@private
	HistoryData *historyData;
	NSMutableArray *views;
}

@property (nonatomic, retain) HistoryData* historyData;

- (void)removeViewAtIndex: (NSInteger)index;

@end
