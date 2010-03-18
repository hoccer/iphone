//
//  SelectContentTableView.m
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SelectContentViewController.h"
#import "NSObject+DelegateHelper.h"

@interface SelectableContent : NSObject
{
	NSString* textLabel;
	SEL action;
}

@property (retain) NSString* textLabel;
@property (assign) SEL action;

- (id) initWithLabel: (NSString*) aTextLabel action: (SEL) anAction;

@end

@implementation SelectableContent

@synthesize textLabel;
@synthesize action;

+ (SelectableContent*) selectableContentWithLabel: (NSString*) aTextLabel action: (SEL) anAction{
	return [[[SelectableContent alloc] initWithLabel:aTextLabel action:anAction] autorelease];	
}

- (id) initWithLabel: (NSString*) aTextLabel action: (SEL) anAction
{
	self = [super init];
	if (self != nil) {
		self.textLabel = aTextLabel;
		self.action = anAction;
	}
	return self;
}

- (void) dealloc
{
	[textLabel release];
	[super dealloc];
}

@end



@implementation SelectContentViewController

@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

- (id) init
{
	self = [super init];
	if (self != nil) {
		selectableContents = [[NSArray alloc] initWithObjects: 
							  [SelectableContent selectableContentWithLabel: @"Contact" action:@selector(selectContacts:)],
							  [SelectableContent selectableContentWithLabel: @"Photo" action:@selector(selectImage:)],
							  [SelectableContent selectableContentWithLabel: @"Text" action:@selector(selectText:)], 
							  nil];
	}
	return self;
}


/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	int index = indexPath.row;
	cell.textLabel.text = [(SelectableContent *)[selectableContents objectAtIndex:index] textLabel];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


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
    
	int index = indexPath.row;
	SEL action = [[selectableContents objectAtIndex:index] action];
	[self.delegate checkAndPerformSelector:action];	
	
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


- (void)dealloc {
	[selectableContents release];
    [super dealloc];
}




@end

