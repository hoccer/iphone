//
//  ChannelViewController.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 04.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "ChannelViewController.h"
#import "SettingsAction.h"

@interface ChannelViewController ()

- (void)registerForKeyboardNotifications;

@end

@implementation ChannelViewController

@synthesize parentNavigationController;
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [parentNavigationController setTitle:@"Channel"];
    }
    else {
        CGRect parentFrame = parentNavigationController.view.frame;
        parentFrame.size.height = parentFrame.size.height - 48;
        [self.view setFrame:parentFrame];
        [self.tableView setFrame:parentFrame];
    }
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
    
    UIView *tbBgView = [[[UIView alloc]init]autorelease];
    tbBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg.png"]];
    tbBgView.opaque = YES;
    self.tableView.backgroundView = tbBgView;
	self.tableView.backgroundColor = [UIColor clearColor];
    
	sections = [[NSMutableArray alloc] init];
	   
	SettingsAction *channelAction = [SettingsAction actionWithDescription:@"Channel" selector:@selector(changedChannel:) type: HCTextField];
    channelAction.defaultValue = @"channel";
	[sections addObject:[NSArray arrayWithObject:channelAction]];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
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



#pragma mark -
#pragma mark 
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

- (void)changedChannel: (UITextField *)textField {
    //NSLog(@"Setting channel: %@", textField.text);
    NSString *oldchannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
    if (![oldchannel isEqualToString:textField.text]) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"channel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotification *notification = [NSNotification notificationWithName:@"clientChannelChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void) keyboardDidAppear:(NSNotification*) n
{
    
//    CGRect bounds = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    bounds = [self.view convertRect:bounds fromView:nil];
//    
//    CGRect tableFrame = tableView.frame;
//    tableFrame.size.height -= bounds.size.height; // subtract the keyboard height
//    //if (self.tabBarController != nil) {
//    tableFrame.size.height += 48; // add the tab bar height
//    //}
//    
//    [UIView beginAnimations:nil context:NULL];
//    
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(shrinkDidEnd:finished:contextInfo:)];
//    tableView.frame = tableFrame;
//    [UIView commitAnimations];
    
}

- (void) shrinkDidEnd:(NSString*) ident finished:(BOOL) finished contextInfo:(void*) nothing {
//    NSIndexPath* sel = [tableView indexPathForSelectedRow];
//    
//    if (![[tableView indexPathsForVisibleRows] containsObject:sel])
//    {
//        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    }
}

- (void) keyboardWillDisappear:(NSNotification*) n
{
    
//    CGRect bounds = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    bounds = [self.view convertRect:bounds fromView:nil];
//    
//    CGRect tableFrame = tableView.frame;
//    tableFrame.size.height += bounds.size.height; // add the keyboard height
//    
//    //if (self.tabBarController != nil) {
//    tableFrame.size.height -= 48; // subtract the tab bar height
//    //}
//    
//    [UIView beginAnimations:nil context:NULL];
//    
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(shrinkDidEnd:finished:contextInfo:)];
//    tableView.frame = tableFrame;
//    [UIView commitAnimations];
//    
//    [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
}

- (void)dealloc {
	[sections release];
	[tableView release];
    [super dealloc];
}

@end
