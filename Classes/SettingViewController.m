//
//  SettingViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutViewController.h"
#import "HelpScrollView.h"

@interface SettingViewController ()

- (void)showTutorial;
- (void)showAbout;
- (void)showWebsite: (NSInteger)index;

@end


@implementation SettingViewController
@synthesize parentNavigationController;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	sections = [[NSMutableArray alloc] init];
	
	NSArray *section1 = [NSArray arrayWithObjects:@"Tutorial", nil];
	[sections addObject:section1];

	NSArray *section3 = [NSArray arrayWithObjects:@"About", nil]; 
	[sections addObject:section3];
	
	NSArray *section2 = [NSArray arrayWithObjects:@"Visit the Hoccer Website", @"Follow Hoccer on Twitter", nil];
	[sections addObject:section2];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return [sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[sections objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [[sections objectAtIndex:[indexPath indexAtPosition:0]] objectAtIndex:[indexPath indexAtPosition:1]];
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			[self showTutorial];
			break;
		case 1:
			[self showAbout];
			break;
		case 2:
			[self showWebsite:[indexPath indexAtPosition:1]];
			break;
		default:
	 		[NSException raise:@"Wrong indexPath in settings menu" format:nil];
			break;
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)showTutorial {
	HelpScrollView *helpView = [[HelpScrollView alloc] initWithNibName:@"HelpScrollView" bundle:nil];
	[parentNavigationController pushViewController:helpView animated:YES];
	[helpView release];
}

- (void)showAbout {
	AboutViewController *aboutView = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	[parentNavigationController pushViewController:aboutView animated:YES];
	[aboutView release];
}

- (void)showWebsite: (NSInteger)index {
	if (index == 1) {
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.twitter.com/hoccer"]];
	} else {
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.hoccer.com"]];
	}
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
	[sections release];
    [super dealloc];
}


@end

