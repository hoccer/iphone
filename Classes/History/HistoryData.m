//
//  HistoryData.m
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "HistoryData.h"
#import "HoccerHistoryItem.h"
#import "HoccerContent.h"
#import "ItemViewController.h"
#import "HoccerContentFactory.h"

@implementation HistoryData
@synthesize hoccerHistoryItemArray;

- (id) init {
    
	self = [super init];
	if (self != nil) {
        
        [self fetchAll];
	}
	return self;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HocHistory" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"HocHistory.sqlite"]];
	
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		//NSLog(@"error: %@", error);
	}    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Data Manipulation Methods


- (void)fetchWithPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HoccerHistoryItem" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    // Order the events by creation date, most recent first.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
    [sortDescriptors release];
    
    // Execute the fetch -- create a mutable copy of the result.
    NSError *error = nil;
    hoccerHistoryItemArray = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    [request release];
}

- (void)fetchAll {
    [self fetchWithPredicate:nil];
}

- (NSInteger)count {
	return [hoccerHistoryItemArray count];
}

- (HoccerHistoryItem *)itemAtIndex: (NSInteger)index {
	return [hoccerHistoryItemArray objectAtIndex:index];
}

- (void)removeItem: (HoccerHistoryItem *)item {
	[hoccerHistoryItemArray removeObject:item];
	[managedObjectContext deleteObject:item];
	

	NSError *error;
	[managedObjectContext save:&error];
}

- (void)addContentToHistory: (ItemViewController *) hoccerController {
    
	HoccerHistoryItem *historyItem =  (HoccerHistoryItem *)[NSEntityDescription insertNewObjectForEntityForName:@"HoccerHistoryItem" inManagedObjectContext:managedObjectContext];
	
	historyItem.filepath = hoccerController.content.filename;
	historyItem.mimeType = [hoccerController.content mimeType];
	historyItem.creationDate = [NSDate date];
	historyItem.upload = [NSNumber numberWithBool: hoccerController.isUpload];
    if([[hoccerController.content mimeType] isEqualToString:@"text/plain"]){
        historyItem.data = hoccerController.content.data;
    }
	
	[hoccerHistoryItemArray insertObject:historyItem atIndex:0];
	
	NSError *error;
	[managedObjectContext save:&error];
}

- (BOOL)containsFile: (NSString *)filename {
	for (HoccerHistoryItem * item in hoccerHistoryItemArray) {
		if ([filename compare: item.filepath] == NSOrderedSame) {
			return YES;
		}
	}
	return NO;
}

@end
