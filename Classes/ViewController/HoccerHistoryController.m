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
#import "HoccerController.h"
#import "HoccerViewController.h"

#import "HoccerContentFactory.h";
#import "ReceivedContentViewController.h"
#import "AdMobView.h"
#import "StoreKitManager.h"

#import "NSString+Regexp.h"

@interface HoccerHistoryController ()

@property (retain) AdMobView *adView;
- (BOOL)rowIsValidListItem: (NSIndexPath *)path;
- (NSInteger)adjustedIndexForAds: (NSIndexPath *)indexPath;

- (void)cleanUp;
@end

@implementation HoccerHistoryController
@synthesize adView;
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
		[self cleanUp];
	}
	return self;
}

- (void) dealloc {
	[historyData release];

	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = 64;
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"history_empty_rowbg.png"]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if (section == 0) {
		rows = [historyData count] + [StoreKitManager bannerCount];
	}
	
	if (rows < 6) {
		rows = 6;
	};
	
	return rows;
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
	[cell viewWithTag:6].hidden = YES;

	NSInteger row = [self adjustedIndexForAds:indexPath];
	if ([StoreKitManager isPropagandaEnabled] && [indexPath row] == 1) {
		[cell viewWithTag:5].hidden = YES;
		
		if (self.adView == nil) {
			self.adView = [AdMobView requestAdWithDelegate:self];	
		}
		
		// self.adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
		// self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		
	    [cell.contentView addSubview:adView];
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_ads_rowbg.png"]] autorelease];

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
		
		cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_rowbg.png"]] autorelease];
	} else {	
		[cell viewWithTag:5].hidden = YES;
		cell.selectionStyle =  UITableViewCellSelectionStyleNone;

		if ((row == 0 && [historyData count] == 0)) {
			[cell viewWithTag:6].hidden = NO;

			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_rowbg.png"]]; 
		} else 	if ( (row == 1 && [historyData count] == 0) || (row == [historyData count] && [historyData count] != 0)) {
			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_firstempty_rowbg.png"]];
		} else {
			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_empty_rowbg.png"]];
		}
	}
		
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![self rowIsValidListItem: indexPath]) {
		return NO;	
	}
	
	return YES;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 1 && [StoreKitManager isPropagandaEnabled]) {
		return 49;
	} else {
	    return aTableView.rowHeight;	
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {

		[self.tableView beginUpdates];
		if ([historyData count] + [StoreKitManager bannerCount] <= 6) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
		}
		
		NSInteger row = [self adjustedIndexForAds:indexPath];
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

	NSInteger row = [self adjustedIndexForAds: indexPath];

	if (row >= [historyData count]) {
		return;
	}
	
	HoccerHistoryItem *item = [historyData itemAtIndex:row];
	
	HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromFile:[item.filepath lastPathComponent] withMimeType:item.mimeType];
	content.persist = YES;
	
	ReceivedContentViewController *detailViewController = [[ReceivedContentViewController alloc] init];
	[detailViewController setHoccerContent:content];
	detailViewController.delegate = self;
	detailViewController.navigationItem.title = [content.filename lastPathComponent];
	
     // Pass the selected object to the new view controller.
	[self.parentNavigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}


- (void)addContentToHistory: (HoccerController *) hoccerController {

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)receiveContentController: (ReceivedContentViewController *)controller wantsToResendContent: (HoccerContent *)content {
	[hoccerViewController setContentPreview: content];
	[hoccerViewController showDesktop];
}


- (void)updateHistoryList {
	[self.tableView reloadData];
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
}

- (void)didReceiveRefreshedAd:(AdMobView *)adView; {
}

- (void)didFailToReceiveAd:(AdMobView *)adView; {
}

- (void)didFailToReceiveRefreshedAd:(AdMobView *)adView; {
}


- (BOOL)rowIsValidListItem: (NSIndexPath *)path {
	if ([StoreKitManager isPropagandaEnabled] && [path row] == 1) { return NO; }
	if ([path row] >= [historyData count] + [StoreKitManager bannerCount]) {	return NO; }
	if ([historyData count] == 0) {	return NO; }
	
	return YES;
}

- (NSInteger)adjustedIndexForAds: (NSIndexPath *)indexPath {
	if ([StoreKitManager isPropagandaEnabled]) {
		return ([indexPath row] > 0) ? [indexPath row] - 1 : [indexPath row];
	} else {
		return [indexPath row];
	}
}


- (void)cleanUp {
	NSString *documentsDirectoryUrl = [HoccerContent contentDirectory];
	
	NSError *error = nil;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryUrl error:&error];
	
	for (NSString *file in files) {
		if (![file contains:@".sqlite"] && ![historyData containsFile: file]) {
			error = nil;
			[[NSFileManager defaultManager] removeItemAtPath:[documentsDirectoryUrl stringByAppendingPathComponent:file] error:&error]; 
		}
	}
}


@end

