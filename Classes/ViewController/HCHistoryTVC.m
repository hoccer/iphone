//
//  HCHistoryTVC.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "HCHistoryTVC.h"
#import "DataManager.h"
#import "HCHistoryImageWidget.h"

@interface HCHistoryTVC ()

@end

@implementation HCHistoryTVC

@synthesize parentNavigationController;
@synthesize hoccerViewController;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.view.frame = self.parentNavigationController.view.frame;
    }
    return self;
}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DataManager *dm = [DataManager sharedDataManager];
    
    dm.historyTVC = self;
    
	self.tableView.rowHeight = kCellHeight;
	//self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"history_empty_rowbg.png"]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
	//[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 560);
}

#pragma mark - Toggle Widget Functions

- (void)toggleButtonPressed:(id)sender
{
    NSLog(@"########## HCHistoryTVC #######  toggleButtonPressed");

    DataManager *dm = [DataManager sharedDataManager];
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    //die folgenden berechnungen dienen der besseren Positionierung beim Aufklappen
    //zuerst aufsummieren aller Widget Höhen
    double sum = 0;
    int i = 0;
    for (UITableViewCell *widget in dm.historyObjectsArray) {
        if (i < indexPath.row) {
            //NSLog(@"sum: %f, add: %f, row: %d", sum, widget.frame.size.height, indexPath.row);
            sum += widget.frame.size.height;
        }
        i++;
    }
    // NSLog(@"sum: %f", sum);
    
    //dann für alle cells im tabellen index grösser 1, animiert an die obere sichtbare Tabellenkante bewegen
    if ([self.tableView numberOfRowsInSection:0] > 1) {
        //die aufgeklappt wurden
        if ((cell.frame.size.height == kCellHeightMax)) {
            //speziell die letzte wird anders behandelt, weil sie nicht bis oben rutschen kann
            if (indexPath.row == [dm.historyObjectsArray count] -1) {
                [self.tableView setContentOffset:CGPointMake(0, sum-45) animated:YES];
            }
            else {
                [self.tableView setContentOffset:CGPointMake(0, sum) animated:YES];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DataManager *dm = [DataManager sharedDataManager];

    return dm.historyObjectsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataManager *dm = [DataManager sharedDataManager];
    
    static NSString *CellIdentifier = @"HCHistoryImageWidget";
    //HCHistoryImageWidget *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    HCHistoryImageWidget *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [dm.historyObjectsArray objectAtIndex:indexPath.row];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if([self widgetIsOpen:indexPath]) {
        return kCellHeightMax;
    }
    return kCellHeight;
}

//- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return aTableView.rowHeight;
//}

- (BOOL)widgetIsOpen:(NSIndexPath *)indexPath
{
    DataManager *dm = [DataManager sharedDataManager];
    
    HCHistoryImageWidget *widget = [dm.historyObjectsArray objectAtIndex:indexPath.row];
    if (widget.widgetIsOpen) {
        return YES;
    }
    else {
        return NO;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self.parentNavigationController release];
    
    [super dealloc];
}

@end
