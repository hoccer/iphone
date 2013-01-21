//
//  SettingViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "SettingViewController.h"
#import "AboutViewController.h"
#import "HelpScrollView.h"
#import "EncryptionSettingsViewController.h"
#import "SettingsAction.h"


@interface SettingViewController ()

- (void)showTutorial;
- (void)showAbout;
- (void)showHoccerWebsite;
- (void)showTwitter;
- (void)showFacebook;
- (void)showBookmarklet;
- (void)showEncryptionSettings;

- (void)registerForKeyboardNotifications;

@end

@implementation SettingViewController
@synthesize parentNavigationController;
@synthesize tableView;
@synthesize hoccerSettingsLogo;
@synthesize versionLabel;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [parentNavigationController setTitle:@"Settings"];
    }
    else {
        CGRect parentFrame = parentNavigationController.view.frame;
        //parentFrame.size.height = parentFrame.size.height - 48;
        [self.view setFrame:parentFrame];
        [self.tableView setFrame:parentFrame];
    }
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
    
    UIView *tbBgView = [[[UIView alloc]init]autorelease];
    tbBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
    tbBgView.opaque = YES;
    self.tableView.backgroundView = tbBgView;
	self.tableView.backgroundColor = [UIColor clearColor];

	[[NSBundle mainBundle] loadNibNamed:@"HoccerSettingsLogo" owner:self options:nil];
    NSString *versionString = [NSString stringWithFormat:@"Version: %@ - %@\n%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"HCCodeName"] ];
    self.versionLabel.text = versionString;
	self.tableView.tableHeaderView = self.hoccerSettingsLogo;
	self.hoccerSettingsLogo = nil;
		
	sections = [[NSMutableArray alloc] init];
	
	SettingsAction *tutorialAction = [SettingsAction actionWithDescription:@"Tutorial" selector:@selector(showTutorial) type: HCContinueSetting];
	[sections addObject:[NSArray arrayWithObject:tutorialAction]];

	SettingsAction *nameAction = [SettingsAction actionWithDescription:@"Name" selector:@selector(changedName:) type: HCTextField];
    nameAction.defaultValue = @"clientName";
	[sections addObject:[NSArray arrayWithObject:nameAction]];

	SettingsAction *playSoundAction = [SettingsAction actionWithDescription:@"Sound-Effects" selector:@selector(switchSound:) type: HCSwitchSetting];
	playSoundAction.defaultValue = @"playSound";
    
    SettingsAction *autoSaveAction = [SettingsAction actionWithDescription:@"Auto-Save" selector:@selector(switchAutoSave:) type:HCSwitchSetting];
    autoSaveAction.defaultValue = @"autoSave";
	
	SettingsAction *bookmarkletAction = [SettingsAction actionWithDescription:@"Install Safari Bookmarklet" selector:@selector(showBookmarklet) type: HCInplaceSetting];
    SettingsAction *abookAction = [SettingsAction actionWithDescription:@"Delete My Contact reference" selector:@selector(deleteContactReference) type: HCInplaceSetting];

	NSArray *section1 = [NSArray arrayWithObjects: playSoundAction, autoSaveAction, bookmarkletAction, abookAction, nil];
	[sections addObject:section1];
    
    NSMutableArray *encryptGroup = [NSMutableArray arrayWithCapacity:3];
    
    SettingsAction *enableTLS = [SettingsAction actionWithDescription:@"Encryption (TLS)" selector:nil type:HCSwitchSetting];
    enableTLS.defaultValue = @"enableTLS";
    [encryptGroup addObject:enableTLS];
    
    SettingsAction *encrypt = [SettingsAction actionWithDescription:@"Encryption (AES E2E)" selector:@selector(encrypt:) type:HCSwitchSetting];
    encrypt.defaultValue = @"encryption";
    encrypting = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
    [encryptGroup addObject:encrypt];
    
    SettingsAction *encryptOptions = [SettingsAction actionWithDescription:@"Expert Settings"selector:@selector(showEncryptionSettings) type:HCContinueSetting];
    [encryptGroup addObject:encryptOptions];
    
    [sections addObject:encryptGroup];
    
	SettingsAction *websiteAction = [SettingsAction actionWithDescription:@"Visit the Hoccer Website" selector:@selector(showHoccerWebsite) type: HCContinueSetting];
	SettingsAction *twitterAction = [SettingsAction actionWithDescription:@"Follow Hoccer on Twitter" selector:@selector(showTwitter) type: HCContinueSetting];
	SettingsAction *facebookAction = [SettingsAction actionWithDescription:@"Become a Fan on Facebook" selector:@selector(showFacebook) type: HCContinueSetting]; 

	NSArray *section3 = [NSArray arrayWithObjects: websiteAction, facebookAction, twitterAction, nil];
	[sections addObject:section3];
	
	SettingsAction *aboutAction = [SettingsAction actionWithDescription:@"About Hoccer" selector:@selector(showAbout) type: HCContinueSetting];
	NSArray *section4 = [NSArray arrayWithObjects:aboutAction, nil]; 
	[sections addObject:section4];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [tableView reloadData];
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 367);
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
	}
    else if (action.type == HCSwitchSetting && ![action.description isEqualToString:@"Encryption (TLS)"]) {
		UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
		[switchView addTarget:self action:action.selector forControlEvents:UIControlEventValueChanged];
		[switchView setOn: [[[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue] boolValue]];
		cell.accessoryView = switchView;
		[switchView release];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    }
    else if (action.type == HCSwitchSetting && [action.description isEqualToString:@"Encryption (TLS)"]) {
		UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        switchView.enabled = NO;
        [switchView setOn: [[[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue] boolValue]];
		cell.accessoryView = switchView;
		[switchView release];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    }
    else if (action.type == HCTextField) {
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 20)];
		[field addTarget:self action:action.selector forControlEvents:UIControlEventValueChanged];
        field.text            = [[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue];
        field.textAlignment   = UITextAlignmentRight;
        field.returnKeyType   = UIReturnKeyDone;
        field.delegate        = self;

        cell.accessoryView = field;
        [field release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    else {
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
	NSInteger section = indexPath.section;
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	SettingsAction *action = [[sections objectAtIndex:section] objectAtIndex:[indexPath indexAtPosition:1]];
	
    if (action.type == HCTextField) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.accessoryView becomeFirstResponder];
        
    }
    else if (action.type != HCSwitchSetting) {
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

- (void)switchAutoSave: (id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:@"autoSave"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showTutorial
{
	HelpScrollView *helpView = [[HelpScrollView alloc] initWithNibName:@"HelpScrollView" bundle:nil];
	helpView.navigationItem.title = @"Tutorial";
	[parentNavigationController pushViewController:helpView animated:YES];
	[helpView release];
}

- (void)changedName: (UITextField *)textField
{
    NSString *oldClientName = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientName"];
    if (![oldClientName isEqualToString:textField.text]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"clientName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotification *notification = [NSNotification notificationWithName:@"clientNameChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)showAbout {
	AboutViewController *aboutView = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	aboutView.navigationItem.title = @"About Hoccer";
	[parentNavigationController pushViewController:aboutView animated:YES];
	[aboutView release];
}

- (void)showEncryptionSettings {
	EncryptionSettingsViewController *viewController = [[EncryptionSettingsViewController alloc] initWithNibName:@"EncryptionSettingsViewController" bundle:nil];
	viewController.navigationItem.title = @"Encryption";
	[parentNavigationController pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)showBookmarklet {
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Install Bookmarklet", nil) 
													 message:NSLocalizedString(@"Safari will be opened now to complete the bookmarklet installation.", nil) 
													delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										   otherButtonTitles:NSLocalizedString(@"Install", nil), nil];
    prompt.tag = 0;
	[prompt show];
	[prompt release];
}

- (void)encrypt: (UISwitch *)sender {
    encrypting = sender.on;
    if (sender.on){
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encryption", nil) 
													 message:NSLocalizedString(@"If you enable end-to-end encryption the current desktop object will be removed and you must choose one or more receivers for your transactions", nil) 
													delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										   otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    prompt.tag = 1;
	[prompt show];
	[prompt release];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"encryption"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotification *notification = [NSNotification notificationWithName:@"encryptionChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
        
  }


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {      
   	switch (alertView.tag) {
        case 0:
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.hoccer.com/___?javascript:window.location='hoccer:'+window.location"]];	
            }	
            break;
        case 1:
            if (buttonIndex == 1) {
                
                [[NSUserDefaults standardUserDefaults] setBool:encrypting forKey:@"encryption"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSNotification *notification = [NSNotification notificationWithName:@"encryptionChanged" object:self];
                [[NSNotificationCenter defaultCenter] postNotification:notification];

            }
            else {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"encryption"];
                [[NSUserDefaults standardUserDefaults] synchronize];

            }
            [tableView reloadData];
        default:
            break;
    }
	
}

- (void)deleteContactReference
{
    int deleted = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:deleted forKey:@"uservCardRef"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Deleted" message:@"The reference was deleted" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
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

#pragma mark -
#pragma mark Text Field and Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell*)textField.superview];
    
    SettingsAction *action = [[sections objectAtIndex:path.section] objectAtIndex:path.row];
    if ([self respondsToSelector:action.selector]) {
        [self performSelector:action.selector withObject:textField];
    }
    
    activeField = nil;
}

- (void)registerForKeyboardNotifications
{ 
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];    
    }
}

- (void)keyboardDidAppear:(NSNotification*)n
{
    CGRect bounds = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    bounds = [self.view convertRect:bounds fromView:nil];
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height -= bounds.size.height; // subtract the keyboard height
    //if (self.tabBarController != nil) {
        tableFrame.size.height += 48; // add the tab bar height
    //}
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(shrinkDidEnd:finished:contextInfo:)];
    tableView.frame = tableFrame;
    [UIView commitAnimations];
  
}

- (void)shrinkDidEnd:(NSString*) ident finished:(BOOL) finished contextInfo:(void*) nothing {
    NSIndexPath* sel = [tableView indexPathForSelectedRow];
    
    if (![[tableView indexPathsForVisibleRows] containsObject:sel])
    {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)keyboardWillDisappear:(NSNotification*) n {
    CGRect bounds = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    bounds = [self.view convertRect:bounds fromView:nil];
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height += bounds.size.height; // add the keyboard height
    
    //if (self.tabBarController != nil) {
        tableFrame.size.height -= 48; // subtract the tab bar height
    //}
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(shrinkDidEnd:finished:contextInfo:)];
    tableView.frame = tableFrame;    
    [UIView commitAnimations];
    
    [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[sections release];
	[hoccerSettingsLogo release];
	[tableView release];
    [versionLabel release];
    [super dealloc];
}


@end

