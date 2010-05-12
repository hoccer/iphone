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
#import "HoccerViewController.h"

#import "HoccerContentFactory.h";
#import "ReceivedContentViewController.h"
#import "AdMobView.h"


@implementation HoccerHistoryController
@synthesize parentNavigationController;
@synthesize hoccerViewController;
@synthesize historyData;

@synthesize historyCell;


#pragma mark -
#pragma mark View lifecycle

- (id) init {
	self = [super init];
	if (self != nil) {
		historyData = [[HistoryData alloc] init];
	}
	return self;
}

- (void) dealloc {
	[historyData release];

	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = 62;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [historyData count] + 1;
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	static NSDateFormatter *dateFormatter = nil;

	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"HistoryView" owner:self options:nil];
        cell = self.historyCell;
		self.historyCell = nil;
	}
    
	if ([historyData count] == [indexPath row]) {
		// [cell.subviews objectAtIndex:0] 
		[cell.contentView addSubview:[AdMobView requestAdWithDelegate:self]];
		return cell;
	}

	cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_rowbg.png"]];
 	HoccerHistoryItem *item = [historyData itemAtIndex:[indexPath row]];

	((UILabel *)[cell viewWithTag:1]).text = [[item filepath] lastPathComponent];
	((UILabel *)[cell viewWithTag:2]).text = [dateFormatter stringFromDate: item.creationDate];
	
	NSString *transferImageName = [item.upload boolValue] ? @"history_icon_upload.png" : @"history_icon_download.png";
	((UIImageView *)[cell viewWithTag:3]).image = [UIImage imageNamed: transferImageName];
	((UIImageView *)[cell viewWithTag:4]).image = [[HoccerContentFactory sharedHoccerContentFactory] thumbForMimeType: item.mimeType];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
		HoccerHistoryItem *item = [historyData itemAtIndex:[indexPath row]];
		[historyData removeItem:item];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	}   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic may go here. Create and push another view controller.
	HoccerHistoryItem *item = [historyData itemAtIndex:[indexPath row]];
	HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromFile:[item.filepath lastPathComponent] withMimeType:item.mimeType];
	content.persist = YES;
	
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
	[historyData addContentToHistory:hocItem];

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)receiveContentController: (ReceivedContentViewController *)controller wantsToResendContent: (HoccerContent *)content {
	[hoccerViewController setContentPreview: content];
	[hoccerViewController showDesktop];
}


#pragma mark -
#pragma mark HoccerAdMobDelegate

- (NSString *)publisherId {
	return @"a14be990ce86624"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewController {
	return self;
}

- (void)didReceiveAd:(AdMobView *)adView; {
	NSLog(@"view: %@ in %s", adView, _cmd);
}

// Sent when a AdMobView successfully makes a subsequent ad request (via requestFreshAd).
// For example an AdView object that shows three ads in its lifetime will see the following
// methods called:  didReceiveAd:, didReceiveRefreshedAd:, and didReceiveRefreshedAd:.
- (void)didReceiveRefreshedAd:(AdMobView *)adView; {
	NSLog(@"view: %@ in %s", adView, _cmd);
}

// Sent when an ad request failed to load an ad.
// Note that this will only ever be sent once per AdMobView, regardless of whether
// new ads are subsequently requested in the same AdMobView.
- (void)didFailToReceiveAd:(AdMobView *)adView; {
	NSLog(@"view: %@ in %s", adView, _cmd);
}

// Sent when subsequent AdMobView ad requests fail (via requestFreshAd).
- (void)didFailToReceiveRefreshedAd:(AdMobView *)adView; {
	
	NSLog(@"view: %@ in %s", adView, _cmd);

}




@end

