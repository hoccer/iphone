//
//  EncryptionSettingsViewController.m
//  Hoccer
//
//  Created by Philip Brechler on 01.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <StoreKit/StoreKit.h>


#import "EncryptionSettingsViewController.h"
#import "SettingsAction.h"
#import "RSAKeyViewController.h"
#import "KnownKeysViewController.h"

@implementation EncryptionSettingsViewController

@synthesize encryptionSettingsHeader;
@synthesize versionLabel;
@synthesize warningLabel;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 367);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
        
    UIView *tbBgView = [[[UIView alloc]init]autorelease];
    tbBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
    tbBgView.opaque = YES;
    self.tableView.backgroundView = tbBgView;
	self.tableView.backgroundColor = [UIColor clearColor];
    
    [[NSBundle mainBundle] loadNibNamed:@"EncryptionSettingsHeader" owner:self options:nil];
    
    NSString *versionString = [NSString stringWithFormat:@"Version: %@ - %@\n%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"HCCodeName"] ];
    self.versionLabel.text = versionString;
    self.warningLabel.text = NSLocalizedString(@"Warning_ExpertsOnly", nil);
    
	self.tableView.tableHeaderView = self.encryptionSettingsHeader;
	self.encryptionSettingsHeader = nil;
    
    sections = [[NSMutableArray alloc] init];

    SettingsAction *autoKeyAction = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_PublicKeyDistribution", nil)
                                                                 selector:@selector(switchAutoKey:)
                                                                     type: HCSwitchSetting];
	autoKeyAction.defaultValue = @"autoKey";
    
    SettingsAction *autoPasswordAction = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_AutoKeyphrase", nil)
                                                                      selector:@selector(switchAutoPassword:)
                                                                          type:HCSwitchSetting];
    autoPasswordAction.defaultValue = @"autoPassword";
    
    SettingsAction *sendPasswordAction = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_TransmitKeyphrase", nil)
                                                                      selector:@selector(switchPasswordAction:)
                                                                          type:HCSwitchSetting];
    sendPasswordAction.defaultValue = @"sendPassword";
    
    SettingsAction *privateKeyAction = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_ShowPrivateKey", nil)
                                                                    selector:@selector(showPrivateKey)
                                                                        type:HCContinueSetting];
    
    SettingsAction *publicKeyAction = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_ShowPublicKey", nil)
                                                                   selector:@selector(showPublicKey)
                                                                       type:HCContinueSetting];

    SettingsAction *keyViewerAction = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_ManagePublicKeys", nil)
                                                                   selector:@selector(showKeyViewer)
                                                                       type:HCContinueSetting];
    
    SettingsAction *encryptionKey = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_SharedKeyphrase", nil)
                                                                 selector:@selector(showSharedKey)
                                                                     type:HCContinueSetting];
    
    NSMutableArray *section1 = [NSMutableArray arrayWithObjects:autoKeyAction,autoPasswordAction,sendPasswordAction,privateKeyAction,publicKeyAction,keyViewerAction,encryptionKey, nil];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autoPassword"]) {
            }
    
    [sections addObject:section1];
    
    SettingsAction *renewUUIDOnStart = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_RenewUUIDOnStart", nil)
                                                                    selector:@selector(renewUUID:) 
                                                                        type:HCSwitchSetting];
    renewUUIDOnStart.defaultValue = @"renewUUID";
    
    
    SettingsAction *renewPublicKeyOnStart = [SettingsAction actionWithDescription:NSLocalizedString(@"SettingsActionDescription_RenewPublicKeyOnStart", nil)
                                                                         selector:@selector(renewPubKey:) 
                                                                             type:HCSwitchSetting];
    renewPublicKeyOnStart.defaultValue = @"renewPubKey";
    
    [sections addObject:[NSArray arrayWithObjects:renewUUIDOnStart,renewPublicKeyOnStart,nil]];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
	return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger section = indexPath.section;
    
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

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {    
    NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell*)textField.superview];
    
    SettingsAction *action = [[sections objectAtIndex:path.section] objectAtIndex:path.row];
    if ([self respondsToSelector:action.selector]) {
        [self performSelector:action.selector withObject:textField];
    }
    
    activeField = nil;
}

#pragma mark - User Actions

- (void)switchAutoPassword: (UISwitch *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"autoPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)switchAutoKey: (UISwitch *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"autoKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (void)switchPasswordAction: (UISwitch *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"sendPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)showPrivateKey {
	RSAKeyViewController *viewController = [[RSAKeyViewController alloc] initWithNibName:@"RSAKeyViewController" bundle:nil];
	viewController.navigationItem.title = NSLocalizedString(@"Title_PrivateKey", nil);
    viewController.key = @"private";
    viewController.keyText.editable = NO;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)showPublicKey {
	RSAKeyViewController *viewController = [[RSAKeyViewController alloc] initWithNibName:@"RSAKeyViewController" bundle:nil];
	viewController.navigationItem.title = NSLocalizedString(@"Title_PublicKey", nil);
    viewController.key = @"public";
    viewController.keyText.editable = NO;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)showKeyViewer {
	KnownKeysViewController *viewController = [[KnownKeysViewController alloc] initWithNibName:@"KnownKeysViewController" bundle:nil];
	viewController.navigationItem.title = NSLocalizedString(@"Title_KnownKeys", nil);;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)showSharedKey {
	RSAKeyViewController *viewController = [[RSAKeyViewController alloc] initWithNibName:@"RSAKeyViewController" bundle:nil];
	viewController.navigationItem.title = NSLocalizedString(@"Title_SharedKey", nil);
    viewController.key = @"shared";
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)renewUUID: (id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:@"renewUUID"];
	[[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void)renewPubKey: (id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender isOn]] forKey:@"renewPubKey"];
	[[NSUserDefaults standardUserDefaults] synchronize];    
}

# pragma mark - Keyboard

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

- (void)dealloc {
    [encryptionSettingsHeader release];
    [sections release];
    [versionLabel release];
    [super dealloc];
}
@end
