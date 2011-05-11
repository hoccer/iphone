//
//  SettingViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "SettingViewController.h"
#import "AboutViewController.h"
#import "HelpScrollView.h"

enum HCSettingsType {
	HCInplaceSetting,
	HCSwitchSetting,
	HCContinueSetting,
    HCTextField
} typedef HCSettingsType;




@interface SettingsAction : NSObject {
	NSString *description;
	SEL selector;
	HCSettingsType type;
	
	id defaultValue;
}

@property (copy) NSString *description;
@property (assign) SEL selector;
@property (assign) HCSettingsType type;
@property (retain) id defaultValue;

+ (SettingsAction *)actionWithDescription: (NSString *)theDescription selector: (SEL)theSelector type: (HCSettingsType)theType;

@end


@implementation SettingsAction
@synthesize description;
@synthesize selector;
@synthesize type;
@synthesize defaultValue;

+ (SettingsAction *)actionWithDescription: (NSString *)theDescription selector: (SEL)theSelector type: (HCSettingsType)theType; {
	SettingsAction *action = [[SettingsAction alloc] init];
	action.description = theDescription;
	action.selector = theSelector;
	action.type = theType;
	
	return [action autorelease];
}

- (void) dealloc {
	[defaultValue release];
	[description release];
	[super dealloc];
}

@end


@interface SettingViewController ()

- (void)showTutorial;
- (void)showAbout;
- (void)showHoccerWebsite;
- (void)showTwitter;
- (void)showFacebook;
- (void)showBookmarklet;

- (void)registerForKeyboardNotifications;

@end


@implementation SettingViewController
@synthesize parentNavigationController;
@synthesize tableView;
@synthesize hoccerSettingsLogo;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
	self.tableView.backgroundColor = [UIColor clearColor];

	[[NSBundle mainBundle] loadNibNamed:@"HoccerSettingsLogo" owner:self options:nil];	
	self.tableView.tableHeaderView = self.hoccerSettingsLogo;
	self.hoccerSettingsLogo = nil;
		
	sections = [[NSMutableArray alloc] init];
	
	SettingsAction *tutorialAction = [SettingsAction actionWithDescription:@"Tutorial" selector:@selector(showTutorial) type: HCContinueSetting];
	[sections addObject:[NSArray arrayWithObject:tutorialAction]];

	SettingsAction *nameAction = [SettingsAction actionWithDescription:@"Name" selector:@selector(editedText:) type: HCTextField];
    nameAction.defaultValue = @"clientName";
	[sections addObject:[NSArray arrayWithObject:nameAction]];

	NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:3];

	SettingsAction *playSoundAction = [SettingsAction actionWithDescription:@"Sound-Effects" selector:@selector(switchSound:) type: HCSwitchSetting];
	playSoundAction.defaultValue = @"playSound";
	
	SettingsAction *bookmarkletAction = [SettingsAction actionWithDescription:@"Install Safari Bookmarklet" selector:@selector(showBookmarklet) type: HCInplaceSetting];
	
	[section1 addObjectsFromArray:[NSArray arrayWithObjects: playSoundAction, bookmarkletAction, nil]];
	[sections addObject:section1];
		
	SettingsAction *websiteAction = [SettingsAction actionWithDescription:@"Visit the Hoccer Website" selector:@selector(showHoccerWebsite) type: HCContinueSetting];
	SettingsAction *twitterAction = [SettingsAction actionWithDescription:@"Follow Hoccer on Twitter" selector:@selector(showTwitter) type: HCContinueSetting];
	SettingsAction *facebookAction = [SettingsAction actionWithDescription:@"Become a Fan on Facebook" selector:@selector(showFacebook) type: HCContinueSetting]; 

	NSArray *section3 = [NSArray arrayWithObjects:websiteAction, facebookAction, twitterAction, nil];
	[sections addObject:section3];
	
    SettingsAction *renewUUIDOnStart = [SettingsAction actionWithDescription:@"New clientId on start" 
                                                                    selector:@selector(renewUUID:) 
                                                                        type:HCSwitchSetting];
    renewUUIDOnStart.defaultValue = @"renewUUID";
    
    [sections addObject:[NSArray arrayWithObject:renewUUIDOnStart]];
    
	SettingsAction *aboutAction = [SettingsAction actionWithDescription:@"About Hoccer" selector:@selector(showAbout) type: HCContinueSetting];
	NSArray *section4 = [NSArray arrayWithObjects:aboutAction, nil]; 
	[sections addObject:section4];
    
    [self registerForKeyboardNotifications];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
    return [[sections objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
		
	NSInteger section = indexPath.section;
	
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	SettingsAction *action = [[sections objectAtIndex:section] objectAtIndex:[indexPath indexAtPosition:1]];
	cell.textLabel.text = action.description;
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	if (action.type == HCContinueSetting) {
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (action.type == HCSwitchSetting) {
		UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
		[switchView addTarget:self action:action.selector forControlEvents:UIControlEventValueChanged];
		[switchView setOn: [[[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue] boolValue]];
		cell.accessoryView = switchView;
		[switchView release];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    } else if (action.type == HCTextField) {    
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 20)];
		[field addTarget:self action:action.selector forControlEvents:UIControlEventValueChanged];
        field.text            = [[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue];
        field.textAlignment   = UITextAlignmentRight;
        field.returnKeyType   = UIReturnKeyDone;
        field.delegate        = self;
        
        cell.accessoryView = field;
        [field release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    [self.view endEditing:YES];
    
	NSInteger section = indexPath.section;
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	SettingsAction *action = [[sections objectAtIndex:section] objectAtIndex:[indexPath indexAtPosition:1]];
	
    if (action.type == HCTextField) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.accessoryView becomeFirstResponder];
        
    } else if (action.type != HCSwitchSetting) {
		[self performSelector:action.selector];	
	}
}

#pragma mark -
#pragma mark Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark -
#pragma mark User Actions

- (void)switchPreview: (id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:@"openInPreview"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchSound: (id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:@"playSound"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)renewUUID: (id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:@"renewUUID"];
	[[NSUserDefaults standardUserDefaults] synchronize];    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *oldClientName = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientName"];
    if (![oldClientName isEqualToString:textField.text]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"clientName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotification *notification = [NSNotification notificationWithName:@"clientNameChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    activeField = nil;
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

- (void)showBookmarklet {
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Install Bookmarklet", nil) 
													 message:NSLocalizedString(@"Safari will be opened now to complete the bookmarklet installation.", nil) 
													delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										   otherButtonTitles:NSLocalizedString(@"Install", nil), nil];
	[prompt show];
	[prompt release];
	

}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {         	
	if (buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.hoccer.com/___?javascript:window.location='hoccer:'+window.location"]];	
	}
}


- (void)showHoccerWebsite { 
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.hoccer.com?piwik_campaign=iphone_settings"]];
}

- (void)showTwitter {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://mobile.twitter.com/hoccer"]];
}

- (void)showFacebook {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://touch.facebook.com/hoccer"]];
}


// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat kbHeight = kbSize.height - 50;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.tableView.frame;
    aRect.size.height -= kbHeight;

    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y + activeField.frame.size.height);
        [self.tableView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
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
	[hoccerSettingsLogo release];
	[tableView release];
    [super dealloc];
}


@end

