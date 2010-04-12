//
//  HocHistory.m
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerHistoryController.h"
#import "HoccerHistoryItem.h"
#import "HoccerContent.h"
#import "HistoryData.h"
#import "HocItemData.h"
#import "HistoryItemViewController.h"
#import "HoccerViewController.h"

#import "HoccerContentFactory.h";
#import "ReceivedContentViewController.h"


@implementation HoccerHistoryController
@synthesize hoccerHistoryItemArray;
@synthesize managedObjectContext;
@synthesize parentNavigationController;
@synthesize hoccerViewController;


#pragma mark -
#pragma mark View lifecycle

- (id) init
{
	self = [super init];
	if (self != nil) {
		HistoryData *historyData = [[HistoryData alloc] init];
		self.managedObjectContext = [historyData managedObjectContext];
		
		[historyData release];
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"HoccerHistoryItem" inManagedObjectContext:managedObjectContext];
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


- (void)viewDidLoad {
    [super viewDidLoad];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) dealloc
{
	[hoccerHistoryItemArray release];
	[managedObjectContext release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [hoccerHistoryItemArray count];
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	HoccerHistoryItem *item = [hoccerHistoryItemArray objectAtIndex:[indexPath row]];
	cell.textLabel.text = [[item filepath] lastPathComponent];
	
	NSString *transferKind = [item.upload boolValue] ? @"uploaded" : @"downloaded";
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", transferKind, [dateFormatter stringFromDate: item.creationDate]];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		HoccerHistoryItem *item = [hoccerHistoryItemArray objectAtIndex:[indexPath row]];
		HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromFile:[item.filepath lastPathComponent] withMimeType:item.mimeType];
		[content removeFromDocumentDirectory];
		
		[hoccerHistoryItemArray removeObject:item];
		[managedObjectContext deleteObject:item];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			NSLog(@"error: %@", error);
		}
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic may go here. Create and push another view controller.
	HoccerHistoryItem *item = [hoccerHistoryItemArray objectAtIndex:[indexPath row]];
	HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromFile:[item.filepath lastPathComponent] withMimeType:item.mimeType];
	
	ReceivedContentViewController *detailViewController = [[ReceivedContentViewController alloc] init];
	[detailViewController setHoccerContent:content];
	detailViewController.delegate = self;
	detailViewController.navigationItem.title = [content.filepath lastPathComponent];
	
     // Pass the selected object to the new view controller.
	[self.parentNavigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)addContentToHistory: (HocItemData *) hocItem {
	HoccerHistoryItem *historyItem =  (HoccerHistoryItem *)[NSEntityDescription insertNewObjectForEntityForName:@"HoccerHistoryItem" inManagedObjectContext:managedObjectContext];
	
	historyItem.filepath = hocItem.content.filepath;
	historyItem.mimeType = [hocItem.content mimeType];
	historyItem.creationDate = [NSDate date];
	historyItem.upload = [NSNumber numberWithBool: hocItem.isUpload];

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[hoccerHistoryItemArray insertObject:historyItem atIndex:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	NSError *error;
	if (![managedObjectContext save:&error]) {
		NSLog(@"error: %@", error);
	}
}

- (void)receiveContentController: (ReceivedContentViewController *)controller wantsToResendContent: (HoccerContent *)content {
	[hoccerViewController setContentPreview: content];
	[hoccerViewController hidePopOverAnimated: YES];

}

@end

