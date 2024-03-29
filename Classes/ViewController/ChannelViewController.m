//
//  ChannelViewController.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 04.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "ChannelViewController.h"
#import "SettingsAction.h"
#import "HoccerAppDelegate.h"
#import "HoccerViewController.h"

@implementation ChannelViewController

@synthesize parentNavigationController;
@synthesize tableView;
@synthesize delegate;
@synthesize contactChannelName;
@synthesize channelTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.helpLabel.text = NSLocalizedString(@"Help_Channel", nil);
    [self.helpLabel sizeToFit];
    CGRect helpFrame = self.helpLabel.frame;
    self.helpLabel.frame = CGRectMake(helpFrame.origin.x, 80.0f, helpFrame.size.width, helpFrame.size.height);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [parentNavigationController setTitle:NSLocalizedString(@"Title_Channel", nil)];
    }
    else {
        CGRect parentFrame = parentNavigationController.view.frame;
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

	SettingsAction *channelAction = [SettingsAction actionWithDescription:NSLocalizedString(@"Button_Channel", nil) selector:@selector(changedChannel:) type:HCTextField];
    channelAction.defaultValue = @"channel";
	[sections addObject:[NSArray arrayWithObject:channelAction]];

//	SettingsAction *channelHelpAction = [SettingsAction actionWithDescription:@"Channel-Help" selector:nil type:HCTextField];
//    channelHelpAction.defaultValue = @"Set the name of the channel";
//	[sections addObject:[NSArray arrayWithObject:channelHelpAction]];

//    SettingsAction *channelContactAction = [SettingsAction actionWithDescription:@"Channel with Contact" selector:@selector(showChannelContact) type:HCContinueSetting];
//	[sections addObject:[NSArray arrayWithObject:channelContactAction]];

//    SettingsAction *channelHelp2Action = [SettingsAction actionWithDescription:@"Channel-Help2" selector:nil type:HCTextField];
//    channelHelp2Action.defaultValue = @"Send content to a contact over a channel";
//	[sections addObject:[NSArray arrayWithObject:channelHelp2Action]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [tableView reloadData];    
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[sections objectAtIndex:section] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSInteger section = indexPath.section;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    
    SettingsAction *action = [[sections objectAtIndex:section] objectAtIndex:[indexPath indexAtPosition:1]];

    if (section == 0) {
        self.channelTextField = [[[UITextField alloc] init] autorelease];
        CGRect cellBounds = cell.bounds;
        CGFloat textFieldBorder = 31.f;
        CGRect aRect = CGRectMake(9.f, 9.f, CGRectGetWidth(cellBounds)-(textFieldBorder), 31.f );
        self.channelTextField.frame = aRect;
        [self.channelTextField setDelegate:self];
        self.channelTextField.clearButtonMode = UITextFieldViewModeAlways;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue] length] > 0) {
            self.channelTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue];
            self.channelTextField.placeholder = @"";
        }
        else {
            self.channelTextField.text = @"";
            self.channelTextField.placeholder = NSLocalizedString(@"Placeholder_ChannelName", nil);
        }
        self.channelTextField.returnKeyType = UIReturnKeyDone;
        self.channelTextField.keyboardType = UIKeyboardTypeDefault;
        self.channelTextField.enablesReturnKeyAutomatically = NO;

        self.channelTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.channelTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.channelTextField.textAlignment = UITextAlignmentLeft;
        [self.channelTextField addTarget:self action:action.selector forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:self.channelTextField];
        
    }
//    else if (section == 1) {
//        UITextField *textView = [[[UITextField alloc] init] autorelease];
//        CGRect cellBounds = cell.bounds;
//        CGFloat textFieldBorder = 31.f;
//        CGRect aRect = CGRectMake(9.f, 9.f, CGRectGetWidth(cellBounds)-(textFieldBorder), 31.f );
//        textView.frame = aRect;
//        textView.text = action.defaultValue;
//        textView.textAlignment = UITextAlignmentLeft;
//        textView.backgroundColor = [UIColor clearColor];
//        [textView setEnabled:NO];
//        textView.textColor = [UIColor whiteColor];
//        textView.font = [UIFont systemFontOfSize:14];
//
//        [cell.contentView addSubview:textView];
//        cell.backgroundColor = [UIColor clearColor];
//    }
//    else if (section == 1) {
//        cell.textLabel.text = action.description;
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        
//        if (action.type == HCContinueSetting) {
//            cell.accessoryView = nil;
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//    }
//    else if (section == 3) {
//        UITextField *textView = [[[UITextField alloc] init] autorelease];
//        CGRect cellBounds = cell.bounds;
//        CGFloat textFieldBorder = 31.f;
//        CGRect aRect = CGRectMake(9.f, 9.f, CGRectGetWidth(cellBounds)-(textFieldBorder), 31.f );
//        textView.frame = aRect;
//        textView.text = action.defaultValue;
//        textView.textAlignment = UITextAlignmentLeft;
//        textView.backgroundColor = [UIColor clearColor];
//        textView.font = [UIFont systemFontOfSize:14];
//        [textView setEnabled:NO];
//        textView.textColor = [UIColor whiteColor];
//        
//        [cell.contentView addSubview:textView];
//        cell.backgroundColor = [UIColor clearColor];
//    }

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark 
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ((textField.text.length > 0) && ((textField.text.length < 6) || (textField.text.length > 32))) {
        
        // NSLog(@"  ### textFieldShouldReturn: in channelViewController textField.text.length < 6");
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Title_ChannelNameNotAccepted", nil)
													   message:NSLocalizedString(@"Message_ChannelNameNotAccepted", nil)
													  delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Button_OK", nil), nil];
		[view show];
		[view release];
    }
    else {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *numberSet = nil;
    numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    
    if (numberSet != nil) {
        NSString *trimmed = [string stringByTrimmingCharactersInSet:numberSet];
        if (string.length > 0) {
            if ([trimmed length] > 0) {
                //                NSLog(@"1 textfieldetxt  = #%@#", textField.text);
                //                NSLog(@"1 trimmed string = #%@#", trimmed);
                return NO;
            }
            else {
                //                NSLog(@"2 textfieldetxt  = #%@#", textField.text);
                //                NSLog(@"2 trimmed string = #%@#", trimmed);
            }
        }
        else {
            //            NSLog(@"3 textfieldetxt  = #%@#", textField.text);
            //            NSLog(@"3 trimmed string = #%@#", trimmed);
            return YES;
        }
    }
//    NSLog(@"4 textfieldetxt  = #%@#", textField.text);
//    NSLog(@"4 replace string = #%@#", string);
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
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

- (void)changedChannel:(UITextField *)textField
{
    if ([self textFieldShouldReturn:textField]) {
        NSString *oldchannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
        if (![oldchannel isEqualToString:textField.text]) {
            
            if (USES_DEBUG_MESSAGES) { NSLog(@"Channel set to:%@",textField.text);}
            [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"channel"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSNotification *notification = [NSNotification notificationWithName:@"clientChannelChanged" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
}

- (void)showChannelContact
{
    if ([delegate respondsToSelector:@selector(showChannelContactPicker)]) {
        [delegate showChannelContactPicker];
    }
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

- (void)dealloc
{
	[sections release];
	[tableView release];
    [super dealloc];
}

@end
