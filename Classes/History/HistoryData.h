//
//  HistoryData.h
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HocItemData;
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

- (NSInteger)count;
- (id)itemAtIndex: (NSInteger)index;
- (void)addContentToHistory: (HocItemData *) hocItem;
- (void)removeItem: (HoccerHistoryItem *)item;

- (BOOL)containsFile: (NSString *)filename;

@end
