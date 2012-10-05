//
//  ChannelViewController.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 04.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "ChannelViewController.h"
#import "SettingsAction.h"
#import "ChannelHelpView.h"

@interface ChannelViewController ()


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
	   
	SettingsAction *channelAction = [SettingsAction actionWithDescription:@"Channel" selector:@selector(changedChannel:) type:HCTextField];
    channelAction.defaultValue = @"channel";
	[sections addObject:[NSArray arrayWithObject:channelAction]];

	SettingsAction *channelHelpAction = [SettingsAction actionWithDescription:@"Channel-Help" selector:nil type:HCTextField];
    channelHelpAction.defaultValue = @"Channel Help - hwoto - example\n Channel Help - hwoto - example\n";
	[sections addObject:[NSArray arrayWithObject:channelHelpAction]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
}

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 367);
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
    

//    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"ChannelHelpView" owner:self options:nil];
//    ChannelHelpView *channelHelpView = nil;
//    
//    for (UIView *view in nibContents) {
//        if ([view isKindOfClass:[channelHelpView class]]) {
//            channelHelpView = (ChannelHelpView *)view;
//            break;
//        }
//    }
//    if (channelHelpView != nil) {
//        [cell.contentView addSubview:channelHelpView];
//    }

    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    
    if (section == 0) {

        SettingsAction *action = [[sections objectAtIndex:section] objectAtIndex:[indexPath indexAtPosition:1]];
        
        UITextField *textField = [[[UITextField alloc] init] autorelease];
        CGRect cellBounds = cell.bounds;
        CGFloat textFieldBorder = 31.f;
        CGRect aRect = CGRectMake(9.f, 9.f, CGRectGetWidth(cellBounds)-(textFieldBorder), 31.f );
        textField.frame = aRect;
        [textField setDelegate:self];
        textField.clearButtonMode = UITextFieldViewModeAlways;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue] length] > 0) {
            textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:action.defaultValue];
            textField.placeholder = @"";
        }
        else {
            textField.text = @"";
            textField.placeholder = @"Channel-Name";
        }
        textField.returnKeyType = UIReturnKeyDone;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.enablesReturnKeyAutomatically = YES;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.textAlignment = UITextAlignmentLeft;
        
        [textField addTarget:self action:action.selector forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:textField];
    }
    else if (section == 1) {
        
//        SettingsAction *action = [[sections objectAtIndex:section] objectAtIndex:[indexPath indexAtPosition:1]];
        
        UITextField *textView = [[[UITextField alloc] init] autorelease];
        CGRect cellBounds = cell.bounds;
        CGFloat textFieldBorder = 31.f;
        CGRect aRect = CGRectMake(9.f, 9.f, CGRectGetWidth(cellBounds)-(textFieldBorder), 31.f );
        textView.frame = aRect;

        //UITextView *textView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 0, 290, 240)] autorelease];
        textView.text = @"Set or delete the name of the channel";
        textView.textAlignment = UITextAlignmentLeft;
        textView.backgroundColor = [UIColor clearColor];
        [textView setEnabled:NO];
        textView.textColor = [UIColor whiteColor];
        //textView.font = [UIFont boldSystemFontOfSize:14];
        
        [cell.contentView addSubview:textView];
        
        cell.backgroundColor = [UIColor clearColor];
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

- (void)changedChannel:(UITextField *)textField {
    NSString *oldchannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
    if (![oldchannel isEqualToString:textField.text]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"channel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotification *notification = [NSNotification notificationWithName:@"clientChannelChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];

//        if (textField.text.length >= 4) {
//            [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"channel"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            NSNotification *notification = [NSNotification notificationWithName:@"clientChannelChanged" object:self];
//            [[NSNotificationCenter defaultCenter] postNotification:notification];
//        }
//        else {
//            textField.text = @"";
//        }
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

- (void)dealloc {
	[sections release];
	[tableView release];
    [super dealloc];
}

@end
