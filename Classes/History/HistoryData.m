//
//  HistoryData.m
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HistoryData.h"
#import "HoccerHistoryItem.h"
#import "HoccerContent.h"
#import "HoccerController.h"
#import "HoccerContentFactory.h"

@implementation HistoryData
@synthesize hoccerHistoryItemArray;

- (id) init {
	self = [super init];
	if (self != nil) {
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"HoccerHistoryItem" inManagedObjectContext:self.managedObjectContext];
		[request setEntity:entity];
		
		// Order the events by creation date, most recent first.
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptor release];
		[sortDescriptors release];
		
		// Execute the fetch -- create a mutable copy of the result.
		NSError *error = nil;
		hoccerHistoryItemArray = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
		
		if (hoccerHistoryItemArray == nil) {
			NSLog(@"error!");
		}
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
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
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
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		NSLog(@"error: %@", error);
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
	if (![managedObjectContext save:&error]) {
		NSLog(@"error: %@", error);
	}
}

- (void)addContentToHistory: (HoccerController *) hoccerController {
	HoccerHistoryItem *historyItem =  (HoccerHistoryItem *)[NSEntityDescription insertNewObjectForEntityForName:@"HoccerHistoryItem" inManagedObjectContext:managedObjectContext];
	
	historyItem.filepath = hoccerController.content.filename;
	historyItem.mimeType = [hoccerController.content mimeType];
	historyItem.creationDate = [NSDate date];
	historyItem.upload = [NSNumber numberWithBool: hoccerController.isUpload];
	
	[hoccerHistoryItemArray insertObject:historyItem atIndex:0];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		NSLog(@"error: %@", error);
	}
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
