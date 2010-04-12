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

@class HocItemData;

@interface HoccerHistoryController : UITableViewController {
	NSMutableArray *hoccerHistoryItemArray;
	NSManagedObjectContext *managedObjectContext;
	
	UINavigationController *parentNavigationController;
	
	HoccerViewController *hoccerViewController;
}

@property (nonatomic, retain) NSMutableArray *hoccerHistoryItemArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UINavigationController *parentNavigationController;
@property (nonatomic, assign) HoccerViewController *hoccerViewController;


- (void)addContentToHistory: (HocItemData *) content;

@end