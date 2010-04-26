//
//  HocHistory.h
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "HoccerHistoryItem.h"

@class HoccerViewController;

@class HoccerConnectionController;
@class HistoryData;

@interface HoccerHistoryController : UITableViewController {
	HistoryData *historyData;
	
	UINavigationController *parentNavigationController;
	HoccerViewController *hoccerViewController;
}

@property (nonatomic, retain) UINavigationController *parentNavigationController;
@property (nonatomic, assign) HoccerViewController *hoccerViewController;
@property (nonatomic, retain) HistoryData *historyData;


- (void)addContentToHistory: (HoccerConnectionController *) content;

@end