//
//  HocHistory.h
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <CoreData/CoreData.h>
#import "HoccerHistoryItem.h"
#import "HCFilterButtonController.h"


@class HoccerViewController;

@class ItemViewController;
@class HistoryData;

@interface HoccerHistoryController : UITableViewController {
	HistoryData *historyData;
	
	UIViewController *rootViewController;
	UINavigationController *parentNavigationController;
	HoccerViewController *hoccerViewController;
    
	UITableViewCell *historyCell;
    
    BOOL inMassEditMode;
    
    NSMutableArray *selectedArray;
}

@property (nonatomic, retain) UINavigationController *parentNavigationController;
@property (nonatomic, assign) HoccerViewController *hoccerViewController;
@property (nonatomic, retain) HistoryData *historyData;
@property (nonatomic, retain) NSMutableArray *selectedArray;

@property (nonatomic, retain) IBOutlet UITableViewCell *historyCell;
@property (nonatomic, retain) IBOutlet UILabel *headerLabel;

@property (nonatomic, retain) HCFilterButtonController *filterController;

- (void)updateHistoryList;
- (void)populateSelectedArray;
- (BOOL)hasEntries;

- (IBAction)enterCustomEditMode:(id)sender;
- (IBAction)deleteSelection:(id)sender;

@end