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

@class HoccerContent;

@interface HocHistory : UITableViewController {
	NSMutableArray *hoccerHistoryItemArray;
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSMutableArray *hoccerHistoryItemArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)addContentToHistory: (HoccerContent *) content;

@end