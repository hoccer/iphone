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

@interface SettingsAction : NSObject {
	NSString *description;
	SEL selector;
}

@property (copy) NSString *description;
@property (assign) SEL selector;

+ (SettingsAction *)actionWithDescription: (NSString *)description selector: (SEL)selector;

@end


@implementation SettingsAction
@synthesize description;
@synthesize selector;

+ (SettingsAction *)actionWithDescription: (NSString *)theDescription selector: (SEL)theSelector; {
	SettingsAction *action = [[SettingsAction alloc] init];
	action.description = theDescription;
	action.selector = theSelector;
	
	return [action autorelease];
}

@end


@interface SettingViewController ()

- (void)showTutorial;
- (void)showAbout;
- (void)showHoccerWebsite;
- (void)showTwitter;
- (void)removePropagange;

@end


@implementation SettingViewController
@synthesize parentNavigationController;
@synthesize tableView;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
	self.tableView.backgroundColor = [UIColor clearColor];
	
	sections = [[NSMutableArray alloc] init];
	
	SettingsAction *tutorialAction = [SettingsAction actionWithDescription:@"Tutorial" selector:@selector(showTutorial)];
	
	NSArray *section1 = [NSArray arrayWithObjects:tutorialAction, nil];
	[sections addObject:section1];


	SettingsAction *aboutAction = [SettingsAction actionWithDescription:@"About Hoccer" selector:@selector(showAbout)];
	NSArray *section2 = [NSArray arrayWithObjects:aboutAction, nil]; 
	[sections addObject:section2];
	
	
	SettingsAction *buyAction = [SettingsAction actionWithDescription:@"Remove Ads" selector:@selector(removePropagange)];
	[sections addObject:[NSArray arrayWithObject:buyAction]];
	
	SettingsAction *websiteAction = [SettingsAction actionWithDescription:@"Visit the Hoccer Website" selector:@selector(showHoccerWebsite)];
	SettingsAction *twitterAction = [SettingsAction actionWithDescription:@"Follow Hoccer on Twitter" selector:@selector(showTwitter)];

	NSArray *section3 = [NSArray arrayWithObjects:websiteAction, twitterAction, nil];
	[sections addObject:section3];

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return [sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[sections objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	SettingsAction *action = [[sections objectAtIndex:[indexPath indexAtPosition:0]] objectAtIndex:[indexPath indexAtPosition:1]];
	cell.textLabel.text = action.description;
	
	if ([indexPath indexAtPosition:0] != 2) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SettingsAction *action = [[sections objectAtIndex:[indexPath indexAtPosition:0]] objectAtIndex:[indexPath indexAtPosition:1]];
	[self performSelector:action.selector];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)showTutorial {
	HelpScrollView *helpView = [[HelpScrollView alloc] initWithNibName:@"HelpScrollView" bundle:nil];
	helpView.navigationItem.title = @"Tutorial";
	[parentNavigationController pushViewController:helpView animated:YES];
	[helpView release];
}

- (void)showAbout {
	AboutViewController *aboutView = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	aboutView.navigationItem.title = @"About Hoccer";
	[parentNavigationController pushViewController:aboutView animated:YES];
	[aboutView release];
}

- (void)showHoccerWebsite {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.hoccer.com"]];
}

- (void)showTwitter {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.twitter.com/hoccer"]];
}

- (void)removePropagange {
	NSLog(@"adfree before: %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"AdFree"]);
	BOOL ad = ![[NSUserDefaults standardUserDefaults] boolForKey:@"AdFree"];
	
	[[NSUserDefaults standardUserDefaults] setBool:ad forKey:@"AdFree"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"adfree after: %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"AdFree"]);
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

