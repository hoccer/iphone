//
//  HocHistory.m
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "HoccerHistoryController.h"
#import "HoccerHistoryItem.h"
#import "HoccerContent.h"
#import "HistoryData.h"
#import "ItemViewController.h"
#import "HoccerViewController.h"

#import "HoccerContentFactory.h"
#import "ReceivedContentViewController.h"
#import "NSString+Regexp.h"
#import "NSFileManager+FileHelper.h"
#import "NSString+StringWithData.h"
#import "UIBarButtonItem+CustomImageButton.h"
#import "HCButtonFactory.h"
#import "CGRectUtils.h"
#import "HCFilterButton.h"


@interface HoccerHistoryController ()

@property (nonatomic, retain) NSArray *filterPredicates;

- (BOOL)rowIsValidListItem: (NSIndexPath *)path;
- (void)cleanUp;

@end

@implementation HoccerHistoryController
@synthesize parentNavigationController;
@synthesize hoccerViewController;
@synthesize historyData;
@synthesize historyCell;
@synthesize selectedArray;


#pragma mark -
#pragma mark View lifecycle

- (id) init {
	self = [super init];
	if (self != nil) {
		historyData = [[HistoryData alloc] init];
		[self cleanUp];
        self.view.frame = self.parentNavigationController.view.frame;
        self.useEditingButtons = NO;
	}
	return self;
}

- (void)dealloc {
    
    self.filterController = nil;
	[historyData release];
	[parentNavigationController release];
	[historyCell release];
	
	[super dealloc];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
    self.tableView.rowHeight = 62;
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"history_empty_rowbg.png"]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setupFilterController];
    [self.filterController buttonWithIndex:0 selected:YES];

    [self populateSelectedArray];
}

- (void)setupFilterController {
        
    // Note: When changing the titles, please make sure their corresponding filter is correctly reflected
    // in the filterPredicates array.
    NSArray *filterTitles = @[NSLocalizedString(@"HistoryFilter_All", nil),
                              NSLocalizedString(@"HistoryFilter_Music", nil),
                              NSLocalizedString(@"HistoryFilter_Images", nil)];
    
    self.filterPredicates = @[@"",
                              @"(mimeType contains[c] 'audio')",
                              @"(mimeType contains[c] 'image')"];
    
    HCFilterButtonController *filterController = [[HCFilterButtonController alloc] initWithTitles:filterTitles
                                                                                           target:self
                                                                                           action:@selector(didChangeFilter:)];
    self.filterController = filterController;
    [filterController release];
        
    // Background view
    CGRect filterFrame = self.tableView.bounds;
    filterFrame.size.height = 400.0f;
    filterFrame.origin.y = -filterFrame.size.height;
    UIView *filterContainer = [[UIView alloc] initWithFrame:filterFrame];
    filterContainer.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    [self.tableView addSubview:filterContainer];
    self.tableView.contentInset = UIEdgeInsetsMake(50.0f, 0.0f, 0.0f, 0.0f);
    filterController.view.frame = CGRectSetOrigin(filterController.view.frame, 6.0, filterFrame.size.height - 40.0f);
    [filterContainer addSubview:filterController.view];
    [filterContainer release];
}

- (void)didChangeFilter:(id)sender {
        
    // Fetch new data
    NSUInteger selectedFilterIndex = [self.filterController selectedIndex];
    NSString *predicateExpression = self.filterPredicates[selectedFilterIndex];
    if (predicateExpression && ![predicateExpression isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateExpression];
        [historyData fetchWithPredicate:predicate];
    }
    else {
        [historyData fetchAll];
    }
    
    [self.tableView reloadData];
    [self updateEditButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateEditButtons];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (inMassEditMode) {
        inMassEditMode = NO;
    }
}

//- (CGSize)contentSizeForViewInPopover {
//    return CGSizeMake(320, 367);
//}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if (section == 0) {
		rows = [historyData count];
	}
	
	if (rows < 6) {
		rows = 6;
	}
	
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
        self.headerLabel.text = NSLocalizedString(@"TipTitle_HistoryList", nil);
	}
	[cell viewWithTag:6].hidden = YES;

    BOOL isItemAnImage = NO;
    
	NSInteger row = [indexPath row];
   
	if (row < [historyData count]) {
		HoccerHistoryItem *item = [historyData itemAtIndex: row];
		//NSLog(@"-->%@", item.mimeType);
        
		[cell viewWithTag:5].hidden = NO;
        
        NSString *shortString = [item.filepath lastPathComponent];
        
        if ([item.mimeType isEqualToString:@"text/plain"] && item.data != nil) {
            NSString *theTextContent = [NSString stringWithData:[item data] usingEncoding:NSUTF8StringEncoding];
            NSRange stringRange = {0, MIN([theTextContent length], 18)};
        
            stringRange = [theTextContent rangeOfComposedCharacterSequencesForRange:stringRange];
        
            shortString = [[theTextContent substringWithRange:stringRange] stringByAppendingString:@" ..."];
        }
        
        ((UILabel *)[cell viewWithTag:1]).text = shortString;
		((UILabel *)[cell viewWithTag:2]).text = [dateFormatter stringFromDate: item.creationDate];
		
		NSString *transferImageName = [item.upload boolValue] ? @"history_icon_upload.png" : @"history_icon_download.png";
		((UIImageView *)[cell viewWithTag:3]).image = [UIImage imageNamed: transferImageName];
        
        if (inMassEditMode){
            
            NSInteger row = [indexPath row];
            if (row < selectedArray.count) {
            
                NSNumber *selected = [selectedArray objectAtIndex:[indexPath row]];
                if ([selected boolValue]){
                    ((UIImageView *)[cell viewWithTag:4]).image = [UIImage imageNamed:@"check_on"];
                }
                else {
                    ((UIImageView *)[cell viewWithTag:4]).image = [UIImage imageNamed:@"check_off"];
                }
            }
        }
        else {
            // nicht sehr schnell
            //HoccerImage *hoccerImage = [[HoccerImage alloc] initWithFilename:[item.filepath lastPathComponent]];
            //[hoccerImage updateImage];
            //((UIImageView *)[cell viewWithTag:4]).image = hoccerImage.thumb;

            if ([item.mimeType startsWith:@"image/"]) {
                isItemAnImage = YES;
                NSString *documentsDirectoryUrl = [[NSFileManager defaultManager] contentDirectory];
                NSString *ext = [[item.filepath lastPathComponent] pathExtension];
                if ((ext == nil) || (ext.length <= 0)) {
                    ext = @"";
                    //NSLog(@"empty ext 1");
                }
                NSString *tmpPath = [[item.filepath lastPathComponent] stringByDeletingPathExtension];
                NSString *thumbPath = [[NSString stringWithFormat:@"%@_thumb", tmpPath] stringByAppendingPathExtension:ext];

                if ([[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectoryUrl stringByAppendingPathComponent:thumbPath]]) {
                    ((UIImageView *)[cell viewWithTag:4]).image = [UIImage imageWithContentsOfFile:[documentsDirectoryUrl stringByAppendingPathComponent:thumbPath]];
                }
                else {
                    ((UIImageView *)[cell viewWithTag:4]).image = [[HoccerContentFactory sharedHoccerContentFactory] thumbForMimeType: item.mimeType];
                }
            }
            else {
                ((UIImageView *)[cell viewWithTag:4]).image = [[HoccerContentFactory sharedHoccerContentFactory] thumbForMimeType: item.mimeType];
            }
        }
		
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle =  UITableViewCellSelectionStyleGray;

        if (row%2) {
            ((UIImageView *)[cell viewWithTag:7]).image = [UIImage imageNamed:@"history_rowbg_image-even.png"];
        }
        else {
            ((UIImageView *)[cell viewWithTag:7]).image = [UIImage imageNamed:@"history_rowbg_image-odd.png"];
        }
        
        // brauchen wir nicht mehr, oder?
//        if (row%2) {
//            ((UIImageView *)[cell viewWithTag:7]).image = [UIImage imageNamed:@"history_rowbg-even.png"];
//        }
//        else {
//            ((UIImageView *)[cell viewWithTag:7]).image = [UIImage imageNamed:@"history_rowbg-odd.png"];
//        }
        //cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_rowbg-odd.png"]] autorelease];
        
        
        
	} else {	
		[cell viewWithTag:5].hidden = YES;
		cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        
		if ((row == 0 && [historyData count] == 0)) {
			[cell viewWithTag:6].hidden = NO;

			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_rowbg.png"]] autorelease]; 
		} else 	if ( (row == 1 && [historyData count] == 0) || (row == [historyData count] && [historyData count] != 0)) {
			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_firstempty_rowbg.png"]] autorelease];
		} else {
			cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_empty_rowbg.png"]] autorelease];
		}
	}
		
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![self rowIsValidListItem: indexPath]) {
		return NO;	
	}
    
    if (inMassEditMode){
        return NO;
    }
	
	return YES;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	    return aTableView.rowHeight;	
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {

		[self.tableView beginUpdates];
		if ([historyData count] <= 6) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
		}
		
		NSInteger row = [indexPath row];
		HoccerHistoryItem *item = [historyData itemAtIndex: row];
		
		[historyData removeItem:item];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
		
		[self.tableView endUpdates];
	}   
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    if (inMassEditMode)
    {
        if ([self hasEntries]) {
            BOOL selected = [[selectedArray objectAtIndex:[indexPath row]] boolValue];
            [selectedArray replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
            [self updateHistoryList];
        }
    }
    else {
        
        NSInteger row = [indexPath row];
        
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
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)addContentToHistory: (ItemViewController *)hoccerController {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)receiveContentController: (ReceivedContentViewController *)controller wantsToResendContent: (HoccerContent *)content {
	[hoccerViewController setContentPreview: content];
	[hoccerViewController showDesktop];
	[hoccerViewController hideHUD];
    
    // trigger upload for content with delayesd file uploaders
    if ([content isKindOfClass:[HoccerMusic class]]) {
        [(HoccerMusic*)content didFinishDataRepresentation];
    } else if ( [content isKindOfClass:[HoccerImage class]]) {
        [(HoccerImage*)content didFinishDataRepresentation];
    }
}


- (void)updateHistoryList {
	[self.tableView reloadData];
}

- (BOOL)rowIsValidListItem: (NSIndexPath *)path {
	if ([path row] >= [historyData count]) { return NO; }
	if ([historyData count] == 0) {	return NO; }
	
	return YES;
}

- (void)cleanUp {
	NSString *documentsDirectoryUrl = [[NSFileManager defaultManager] contentDirectory];
	
	NSError *error = nil;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryUrl error:&error];
    for (NSString *file in files) {
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDir];
        if (isDir) {
            continue;
        }
        
        if (![file contains:@".sqlite"] && ![historyData containsFile: file]) {
			error = nil;
			[[NSFileManager defaultManager] removeItemAtPath:[documentsDirectoryUrl stringByAppendingPathComponent:file] error:&error]; 
		}
	}
}

- (void)populateSelectedArray
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[historyData count]];
    for (int i=0; i < [historyData count]; i++)
        [array addObject:[NSNumber numberWithBool:NO]];
    self.selectedArray = array;
    [array release]; 
}

- (BOOL)hasEntries {
    return [historyData count] > 0;
}

- (IBAction)enterCustomEditMode:(id)sender {
    
    inMassEditMode = !inMassEditMode;
    
    [self populateSelectedArray];
    [self updateEditButtons];
    [self updateHistoryList];

}

- (void)updateEditButtons {
    
    if (!self.useEditingButtons) return;
    
    self.filterController.enabled = !inMassEditMode;
    
    if (inMassEditMode) {
        
        UIBarButtonItem *deleteButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Delete", nil)
                                                                    style:HCBarButtonRed
                                                                   target:self
                                                                   action:@selector(deleteSelection:)];
        
        UIBarButtonItem *cancelButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Cancel", nil)
                                                                    style:HCBarButtonBlack
                                                                   target:self
                                                                   action:@selector(enterCustomEditMode:)];
        
        [hoccerViewController.navigationItem setRightBarButtonItem:deleteButton];
        [hoccerViewController.navigationItem setLeftBarButtonItem:cancelButton];
        [cancelButton release];
        [deleteButton release];
    }
    else {
        
        UIBarButtonItem *doneButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Done", nil)
                                                                  style:HCBarButtonBlack
                                                                 target:hoccerViewController
                                                                 action:@selector(cancelPopOver)];
        
        UIBarButtonItem *editButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Edit", nil)
                                                                  style:HCBarButtonBlack
                                                                 target:self
                                                                 action:@selector(enterCustomEditMode:)];
        
        [hoccerViewController.navigationItem setRightBarButtonItem:doneButton];
        [hoccerViewController.navigationItem setLeftBarButtonItem:editButton];
        [editButton release];
        [doneButton release];
        
        [editButton setEnabled:[self hasEntries]];
    }
}

- (IBAction)deleteSelection:(id)sender {

    NSMutableArray *rowsToBeDeleted = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (NSNumber *rowSelected in selectedArray)
    {
        if ([rowSelected boolValue])
        {
            HoccerHistoryItem *item = [[historyData itemAtIndex:index] autorelease];
            [rowsToBeDeleted addObject:item];

        }  
        index++;
    }
    
    for (HoccerHistoryItem *value in rowsToBeDeleted) {
        [historyData removeItem:value];
    }
    
    [self cleanUp];

    [self enterCustomEditMode:nil];
}


@end

