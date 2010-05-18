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

#define kBannerCount 1






@interface HoccerHistoryController()

- (BOOL)rowIsValidListItem: (NSIndexPath *)path;

@end

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
	NSInteger rows = 0;
	if (section == 0) {
		rows = [historyData count] + kBannerCount;
	}
	
	if (rows < 6) {
		rows = 6;
	};
	
	return rows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"row %d", [indexPath row]);
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
	cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_rowbg.png"]];
	
	NSInteger row = ([indexPath row] > 0) ? [indexPath row] - 1 : [indexPath row];
	if ([indexPath row] == 1) {
		[cell viewWithTag:5].hidden = YES;
		
		UIView *adView = [AdMobView requestAdWithDelegate:self];
		adView.center = cell.contentView.center;
		[cell.contentView addSubview:adView];
	} else if (row < [historyData count]) {
		HoccerHistoryItem *item = [historyData itemAtIndex: row];
		
		[cell viewWithTag:5].hidden = NO;
		((UILabel *)[cell viewWithTag:1]).text = [[item filepath] lastPathComponent];
		((UILabel *)[cell viewWithTag:2]).text = [dateFormatter stringFromDate: item.creationDate];
		
		NSString *transferImageName = [item.upload boolValue] ? @"history_icon_upload.png" : @"history_icon_download.png";

		((UIImageView *)[cell viewWithTag:3]).image = [UIImage imageNamed: transferImageName];
		((UIImageView *)[cell viewWithTag:4]).image = [[HoccerContentFactory sharedHoccerContentFactory] thumbForMimeType: item.mimeType];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;		
		cell.selectionStyle =  UITableViewCellSelectionStyleGray;
	} else {	
		[cell viewWithTag:5].hidden = YES;
		cell.selectionStyle =  UITableViewCellSelectionStyleNone;
	}


		
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self rowIsValidListItem: indexPath]) {
		return NO;	
	}
	
	return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[self.tableView beginUpdates];
		if ([historyData count] + kBannerCount <= 6) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
		}
		
		NSInteger row = ([indexPath row] > 0) ? [indexPath row] - 1 : [indexPath row];
		HoccerHistoryItem *item = [historyData itemAtIndex: row];
		
		[historyData removeItem:item];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
		
		[self.tableView endUpdates];
		[self.tableView reloadData];
	}   
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];

	NSInteger row = ([indexPath row] > 0) ? [indexPath row] - 1 : [indexPath row];

	if (row >= [historyData count]) {
		return;
	}
	
	HoccerHistoryItem *item = [historyData itemAtIndex:row];
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

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)receiveContentController: (ReceivedContentViewController *)controller wantsToResendContent: (HoccerContent *)content {
	[hoccerViewController setContentPreview: content];
	[hoccerViewController showDesktop];
}


- (void)updateHistoryList {
	[self.tableView reloadData];
	//[self.tableView beginUpdates];
//	if ([historyData count] + kBannerCount <= 6) {
//		NSIndexPath *removePath = [NSIndexPath indexPathForRow:5 inSection:0];
//		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:removePath] withRowAnimation:UITableViewRowAnimationNone];
//	}
//	
//	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//	[self.tableView endUpdates];
}


#pragma mark -
#pragma mark HoccerAdMobDelegate

- (NSString *)publisherId {
	return @"a14be2c38131979"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewController {
	return hoccerViewController;
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


- (BOOL)rowIsValidListItem: (NSIndexPath *)path {
	return ([historyData count] == 0 || [path row] >= [historyData count] + kBannerCount || [path row] == 1);
}

@end

