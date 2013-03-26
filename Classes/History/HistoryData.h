//
//  HistoryData.h
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemViewController;
@class HoccerHistoryItem;

@interface HistoryData : NSObject {
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	
	
	NSMutableArray *hoccerHistoryItemArray;
}

@property (nonatomic, retain) NSMutableArray *hoccerHistoryItemArray;

- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *) managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSString *)applicationDocumentsDirectory;

- (void)fetchAll;
- (void)fetchMusic;
- (void)fetchWithPredicate:(NSPredicate *)predicate;

- (NSInteger)count;
- (id)itemAtIndex: (NSInteger)index;
- (void)addContentToHistory: (ItemViewController *) hoccerController;
- (void)removeItem: (HoccerHistoryItem *)item;

- (BOOL)containsFile: (NSString *)filename;

@end
