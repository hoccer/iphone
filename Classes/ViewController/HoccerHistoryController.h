//
//  HocHistory.h
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <CoreData/CoreData.h>
#import "HoccerHistoryItem.h"
#import "AdMobDelegateProtocol.h"

@class HoccerViewController;

@class HoccerController;
@class HistoryData;

@interface HoccerHistoryController : UITableViewController <AdMobDelegate> {
	HistoryData *historyData;
	
	UIViewController *rootViewController;
	UINavigationController *parentNavigationController;
	HoccerViewController *hoccerViewController;
	
	UITableViewCell *historyCell;

	AdMobView *adView;
}

@property (nonatomic, retain) UINavigationController *parentNavigationController;
@property (nonatomic, assign) HoccerViewController *hoccerViewController;
@property (nonatomic, retain) HistoryData *historyData;

@property (nonatomic, retain) IBOutlet UITableViewCell *historyCell;

- (void)updateHistoryList;

@end