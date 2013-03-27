//
//  HoccerViewControlleriPad.m
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "HoccerViewControlleriPad.h"
#import "DesktopView.h"
#import "HoccerText.h"
#import "StatusViewController.h"
#import "GroupStatusViewController.h"
#import "SelectContentController.h"
#import "HelpScrollView.h"
#import "HoccerHistoryController.h"
#import "ItemViewController.h"
#import "DesktopDataSource.h"
#import "SettingViewController.h"
#import "ChannelViewController.h"
#import "HoccingRulesIPad.h"
#import "GesturesInterpreter.h"
#import "HoccerHoclet.h"
#import "CustomNavigationBar.h"
#import "KSCustomPopoverBackgroundView.h"

#import "StatusBarStates.h"
#import "ConnectionStatusViewController.h"
#import "HoccerAppDelegate.h"
#import "HCButtonFactory.h"


@interface HoccerViewControlleriPad ()

@property (retain) ActionElement* delayedAction;
@property (retain, nonatomic) id <ContentSelectController> activeContentSelectController;


- (void)showPopOver: (UIViewController *)popOverView;
- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)showSelectContentView;
- (void)removePopOverFromSuperview;
- (void)hidePopOverAnimated: (BOOL) animate;
- (void)updateGroupButton;
- (void)showGroupButton;
- (void)updateEncryptionIndicator;
- (void)showEncryption;
- (void)showGroupAndEncryption;
- (void)setProperPullDownBackgroundImage: (BOOL) isPortrait;
- (void)setProperSubViewSizes: (BOOL) isPortrait;



@end

@implementation HoccerViewControlleriPad
@synthesize hoccerHistoryController;
@synthesize delayedAction;
@synthesize auxiliaryView;
@synthesize activeContentSelectController;
@synthesize navigationItem;

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    // Titles of UITabBarItems are keys defined in Localizable.strings, translate them if possible
    for (UITabBarItem *item in self.tabBar.items) {
        
        NSString *localizedTitle = NSLocalizedString(item.title, nil);
        if ([localizedTitle isEqualToString:item.title]) localizedTitle = @"";
        item.title = localizedTitle;
    }
    
	hoccingRules = (HoccingRules *)[[HoccingRulesIPad alloc] init];
	isPopUpDisplayed = FALSE;
	
	navigationController.navigationBar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hoccer_bar.png"]];
	
	navigationItem = [[navigationController visibleViewController].navigationItem retain];
	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];
    
	navigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 
												 self.view.frame.size.height - tabBar.frame.size.height); 
    
	[self.view addSubview:navigationController.view];
    
    desktopView.shouldSnapToCenterOnTouchUp = NO;
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    
    if (isPortrait){
        self.defaultOrigin = CGPointMake(235, 100);
    }
    else {
        self.defaultOrigin = CGPointMake(350, 100);
    }     
    
  	
	self.hoccerHistoryController = [[[HoccerHistoryController alloc] init] autorelease];
	self.hoccerHistoryController.parentNavigationController = navigationController;
	self.hoccerHistoryController.hoccerViewController = self;
	self.hoccerHistoryController.historyData = historyData;
	
    
    BOOL hasEncryption = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
    desktopView.backgroundStyle = hasEncryption ? HCDesktopBackgroundStyleLock : HCDesktopBackgroundStylePerforated;

    
    [self setProperPullDownBackgroundImage: isPortrait];
 
    
	[desktopView insertSubview:statusViewController.view atIndex:2];
	
    [desktopView insertSubview:errorViewController.view atIndex:1];
    
    [self setProperSubViewSizes:isPortrait];

    
    CGRect infoRect = CGRectMake(0, 0, 320, 400);
    groupViewController = [[GroupStatusViewController alloc] init];
	groupViewController.view.frame = infoRect;
	groupViewController.largeBackground = [UIImage imageNamed:@"statusbar_small.png"];
	[groupViewController setState:[LocationState state]];
    groupViewController.delegate = self;
    
    // Fix different autosizing behavior of tableview required for use in popover on iPad
    NSArray* subviews = groupViewController.view.subviews;
    for (UIView *subview in subviews) {
        // NSLog(@"%@", subview);
        subview.autoresizingMask = 0;
        // NSLog(@"%@", subview);
    }
    if ([subviews count] != 1) {
        NSLog(@"WARNING, groupViewController should have only one subview, found %i",[subviews count]);
    }
	
	helpController = [[HelpController alloc] initWithController:navigationController];
	[helpController viewDidLoad];
    
    self.pullDownView.desktopView = desktopView;
    [self movePullDownToNormalPosition];
	
	[self showHud];
    [self updateGroupButton];
    //[self updateEncryptionIndicator];
    
    // Pseudo-segmented control at top left
    NSArray *leftNavImages = @[[UIImage imageNamed:@"nav_bar_btn_history.png"],
                               [UIImage imageNamed:@"nav_bar_btn_channel.png"],
                               [UIImage imageNamed:@"nav_bar_btn_settings.png"]];
    
    HCBarButtonItem *leftNavItem = [HCButtonFactory newSegmentedControlWithImages:leftNavImages
                                                                           target:self
                                                                           action:@selector(didSelectLeftNavButton:)];
    
    self.navigationItem.leftBarButtonItem = leftNavItem;
    [leftNavItem release];
    [leftNavButtons release];
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSMutableArray *modifyMe = [[tabBar items] mutableCopy];
        [modifyMe removeObjectAtIndex:0];
        NSArray *newItems = [[NSArray alloc] initWithArray:modifyMe];
        [tabBar setItems:newItems animated:NO];
        [newItems release];
        [modifyMe release];
    }
}


- (void) dealloc {
    
	[hoccerHistoryController release];
	[navigationController release];
	[navigationItem release];
	[tabBar release];
	[auxiliaryView release];
	[delayedAction release];
	[helpController release];
    [groupSizeButton release];
    [activeContentSelectController release];
    [contentPopOverController release];
    [settingsPopOverController release];
    [historyPopOverController release];
    [channelPopOverController release];
	
	[super dealloc];
}

- (void)setContentPreview: (HoccerContent *)content {
	[super setContentPreview:content];
    groupSizeButton.hidden = NO;
}

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller {
    self.activeContentSelectController = controller;
    
    [self hidePopOverAnimated:  NO];
    contentPopOverController = [[UIPopoverController alloc] initWithContentViewController:controller.viewController];
    contentPopOverController.popoverContentSize = CGSizeMake(320, 400);
    contentPopOverController.delegate = self;
    if ([contentPopOverController respondsToSelector:@selector(setPopoverBackgroundViewClass:)]){
        [contentPopOverController setPopoverBackgroundViewClass:[KSCustomPopoverBackgroundView class]];
    }
    CGFloat tabBarHeight = self.tabBar.bounds.size.height;
    CGRect rect;
    BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    if (isPortrait){
        switch (self.tabBar.selectedItem.tag) {
            case 2: {
                if ([self.tabBar.items count] == 7){
                    rect = CGRectMake(140, 0, tabBarHeight, tabBarHeight);
                }
                else {
                    rect = CGRectMake(86, 0, tabBarHeight, tabBarHeight);
                }
                break;
            }
            case 5: {
                if ([self.tabBar.items count] == 7){
                    rect = CGRectMake(470, 0, tabBarHeight, tabBarHeight);
                }
                else {
                    rect = CGRectMake(415, 0, tabBarHeight, tabBarHeight);
                }
                break;
            }
            default: {
                rect = CGRectMake(0, 0, tabBarHeight, tabBarHeight);
            }
        }
    }
    else {
        switch (self.tabBar.selectedItem.tag) {
            case 2: {
                if ([self.tabBar.items count] == 7){
                    rect = CGRectMake(264, 0, tabBarHeight, tabBarHeight);
                }
                else {
                    rect = CGRectMake(214, 0, tabBarHeight, tabBarHeight);
                }
                break;
            }
            case 5: {
                if ([self.tabBar.items count] == 7){
                    rect = CGRectMake(595, 0, tabBarHeight, tabBarHeight);
                }
                else {
                    rect = CGRectMake(540, 0, tabBarHeight, tabBarHeight);
                }
                break;
            }
            default: {
                rect = CGRectMake(0, 0, tabBarHeight, tabBarHeight);
            }
        }

    }

    [contentPopOverController presentPopoverFromRect:rect inView:self.tabBar permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)dismissContentSelectViewController {
    
    self.activeContentSelectController = nil;
    [contentPopOverController dismissPopoverAnimated:YES];
    self.tabBar.selectedItem = nil;
    [self movePullDownToNormalPosition];
}

- (IBAction)toggleSettings: (id)sender {
    if (!settingsPopOverNavigationController) {
        settingsPopOverNavigationController = [[UINavigationController alloc]initWithRootViewController:self.settingViewController];
        self.settingViewController.parentNavigationController = settingsPopOverNavigationController;
        [settingsPopOverNavigationController setTitle:NSLocalizedString(@"Title_Settings", nil)]; 
    }
    if (!settingsPopOverController) {
        settingsPopOverController = [[UIPopoverController alloc]initWithContentViewController:settingsPopOverNavigationController];
        [settingsPopOverController setPopoverContentSize:CGSizeMake(320, 600)];
        if ([settingsPopOverController respondsToSelector:@selector(setPopoverBackgroundViewClass:)]){
            [settingsPopOverController setPopoverBackgroundViewClass:[KSCustomPopoverBackgroundView class]];
        }
    }
    if ([settingsPopOverController isPopoverVisible]){
        [settingsPopOverController dismissPopoverAnimated:YES];
    }
    else {
        [settingsPopOverController presentPopoverFromRect:CGRectMake(180, 0, 50, 44) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [historyPopOverController dismissPopoverAnimated:NO];
        [channelPopOverController dismissPopoverAnimated:NO];
    }
}

- (IBAction)toggleChannel: (id)sender {
    if (!channelPopOverNavigationController) {
        channelPopOverNavigationController = [[UINavigationController alloc]initWithRootViewController:self.channelViewController];
        self.channelViewController.parentNavigationController = channelPopOverNavigationController;
        [channelPopOverNavigationController setTitle:NSLocalizedString(@"Title_Channel", nil)];
    }
    if (!channelPopOverController) {
        channelPopOverController = [[UIPopoverController alloc]initWithContentViewController:channelPopOverNavigationController];
        [channelPopOverController setPopoverContentSize:CGSizeMake(320, 600)];
        if ([channelPopOverController respondsToSelector:@selector(setPopoverBackgroundViewClass:)]){
            [channelPopOverController setPopoverBackgroundViewClass:[KSCustomPopoverBackgroundView class]];
        }
    }
    if ([channelPopOverController isPopoverVisible]){
        [channelPopOverController dismissPopoverAnimated:YES];
    }
    else {
        [channelPopOverController presentPopoverFromRect:CGRectMake(100, 0, 50, 44) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [historyPopOverController dismissPopoverAnimated:NO];
        [settingsPopOverController dismissPopoverAnimated:NO];
    }
}


- (IBAction)toggleHistory: (id)sender {
	
    if (!historyPopOverNavigationController) {
        historyPopOverNavigationController = [[UINavigationController alloc]initWithRootViewController:self.hoccerHistoryController];
        self.hoccerHistoryController.parentNavigationController = historyPopOverNavigationController;
        [historyPopOverNavigationController setTitle:NSLocalizedString(@"Title_History", nil)];
    }
    if (!historyPopOverController) {
        historyPopOverController = [[UIPopoverController alloc]initWithContentViewController:historyPopOverNavigationController];
        if ([historyPopOverController respondsToSelector:@selector(setPopoverBackgroundViewClass:)]){
            [historyPopOverController setPopoverBackgroundViewClass:[KSCustomPopoverBackgroundView class]];
        }
        [historyPopOverController setPopoverContentSize:CGSizeMake(320, 600)];
    }
    if ([historyPopOverController isPopoverVisible]){
        [historyPopOverController dismissPopoverAnimated:YES];
    }
    else {
        [historyPopOverController presentPopoverFromRect:CGRectMake(20, 0, 50, 44) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];        
        [settingsPopOverController dismissPopoverAnimated:NO];
        [channelPopOverController dismissPopoverAnimated:NO];

    }
}


- (IBAction)selectMyContact:(id)sender {
    [super selectMyContact:nil];
    
    tabBar.selectedItem = nil;
}

- (IBAction)selectText:(id)sender {
    [super selectText:nil];
    
    tabBar.selectedItem = nil;
}

- (IBAction)selectPasteboard:(id)sender {
    [super selectPasteboard:nil];
    
    tabBar.selectedItem = nil;
}


- (void)didSelectLeftNavButton:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 0:
            [self toggleHistory:nil];
            break;
        case 1:
            [self toggleChannel:nil];
            break;
        case 2:
            [self toggleSettings:nil];
            break;
        default:
            break;
    }
}

- (void)showDesktop {
    tabBar.selectedItem = nil;
}

- (void)showChannelView {
	[self hidePopOverAnimated:YES];
    tabBar.selectedItem = nil;
}


- (void)showSelectContentView {
	SelectContentController *selectContentViewController = [[SelectContentController alloc] init];
	selectContentViewController.delegate = self;
	
	[self showPopOver: selectContentViewController];
	[selectContentViewController release];
}

- (void)showPopOver: (UIViewController *)popOverView  {
	[popOverView viewWillAppear:YES];
	
	gestureInterpreter.delegate = nil;
	self.auxiliaryView = popOverView;
	
	CGRect popOverFrame = popOverView.view.frame;
	popOverFrame.size = desktopView.frame.size;
	popOverFrame.origin= CGPointMake(0, self.view.frame.size.height);
	popOverView.view.frame = popOverFrame;	
	
	[desktopView insertSubview:popOverView.view atIndex:1];
    
	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.3];
	
	popOverFrame.origin = CGPointMake(0, 0);
	popOverView.view.frame = popOverFrame;
	[UIView commitAnimations];
	
	isPopUpDisplayed = TRUE;
	
    [groupViewController hideStatus];
	[popOverView viewDidAppear:YES];
}

- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	[self removePopOverFromSuperview];
}

- (void)removePopOverFromSuperview
{

    [auxiliaryView.view removeFromSuperview];

	self.auxiliaryView = nil;
	
	isPopUpDisplayed = NO;
	
	[self.delayedAction perform];
	self.delayedAction = nil;
}

- (void)hidePopOverAnimated: (BOOL) animate {
	if (self.auxiliaryView != nil) {		
		CGRect selectContentFrame = self.auxiliaryView.view.frame;
		selectContentFrame.origin = CGPointMake(0, self.view.frame.size.height);
		
		if (animate) {
			[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
			[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.2];
			self.auxiliaryView.view.frame = selectContentFrame;
			
			[UIView commitAnimations];
		} else {
			self.auxiliaryView.view.frame = selectContentFrame;
			[self removePopOverFromSuperview];
		}
	}
	
	self.gestureInterpreter.delegate = self;
	
	[navigationController popToRootViewControllerAnimated:YES];
	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];
    
    [self showGroupAndEncryption];
    //navigationItem.leftBarButtonItem = nil;
    [self updateEncryptionIndicator];
}

- (IBAction)selectAutoReceive:(id)sender
{
    if (USES_DEBUG_MESSAGES) {  NSLog(@"#### HoccerViewControllerIPad selectAutoReceive ####");}
    
    [super selectAutoReceive:sender];
    
    self.tabBar.selectedItem = nil;
}

#pragma mark -
#pragma mark Linccer Delegate Methods
- (void)linccer:(HCLinccer *)linccer didUpdateGroup:(NSArray *)group {
    
    if (USES_DEBUG_MESSAGES) {  NSLog(@"didUpdateGroup");}
    NSMutableArray *others = [NSMutableArray arrayWithCapacity:[group count]];
    for (NSDictionary *dict in group) {
        if (![[dict objectForKey:@"id"] isEqual:[self.linccer uuid]]) {
            [others addObject:dict];            
        }
    }
    
    [groupViewController setGroup:others];
    
    [self updateGroupButton];
}

- (void)groupStatusViewController:(GroupStatusViewController *)controller didUpdateSelection:(NSArray *)clients {
    NSMutableArray *clientIds = [NSMutableArray array];
    for (NSDictionary *dict in clients) {
        [clientIds addObject:[dict objectForKey:@"id"]];
    }
    
    NSMutableDictionary *userInfo = [[linccer.userInfo mutableCopy] autorelease];
    if (userInfo == nil) {
        userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    [userInfo setObject:clientIds forKey:@"selected_clients"];
    
    linccer.userInfo = userInfo;
    [self updateGroupButton];
}


#pragma mark -
#pragma mark TapBar delegate Methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (USES_DEBUG_MESSAGES) {  NSLog(@"tabBar didSelectItem %@", item);}
    
    [self stopAutoReceiveAndHidePullDown];

	switch (item.tag) {
		case 1:
			[self selectCamera:nil];
			break;
		case 2:
			[self selectImage:nil];
			break;
		case 3:
			[self selectMusic:nil];
			break;
        case 4:
            [self selectText:nil];
            break;
        case 5:
            [self selectContact:nil];
            break;
        case 6:
            [self selectMyContact:nil];
            break;
        case 7:
            [self selectPasteboard:nil];
            break;
		default:
			//NSLog(@"this should not happen");
			break;
	}
}

- (void)handleError: (NSError *)error {
    [super handleError:error];
    
    if (error != nil && [[error domain] isEqual:NSURLErrorDomain]) {
        [groupSizeButton setTitle: @"X  " forState:UIControlStateNormal];
        [groupViewController setGroup:nil];
    }
}

#pragma mark -
#pragma mark User Actions
- (void)cancelPopOver {
    if (USES_DEBUG_MESSAGES) {  NSLog(@"cancelPopOver");}
	tabBar.selectedItem = nil;
	[self hidePopOverAnimated:YES];
}

- (void)clientChannelChanged:(NSNotification *)notification
{
    if (USES_DEBUG_MESSAGES) {  NSLog(@"clientChannelChanged");}

    [self updateGroupButton];
    
    [linccer updateEnvironment];
}

#pragma mark -
#pragma mark Private Methods
- (void)updateGroupButton {
    
    if (USES_DEBUG_MESSAGES) {  NSLog(@"updateGroupButton");}
    
	if (navigationItem.titleView == nil) {
        // NSLog(@"updateGroupButton: titleView is nil, returning");
		return;
	}
	
    if (groupSizeButton == nil) {
        // NSLog(@"updateGroupButton: groupSizeButton is nil, creating");
        groupSizeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [groupSizeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [groupSizeButton addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
        [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_off"] forState:UIControlStateNormal];
        groupSizeButton.frame = CGRectMake(-10, 0, 56, 44);
    }
    
    NSInteger groupCount = [[groupViewController group] count];
    NSString *text = nil;
    if (groupCount < 1) {
        text = @"0   ";
        clientSelected = NO;
    } else if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"selected_clients"] count] > 0) {
        text = [NSString stringWithFormat: @"%d   ", [[[NSUserDefaults standardUserDefaults] arrayForKey:@"selected_clients"]  count]];
        clientSelected = YES;
    } else {
        text = [NSString stringWithFormat: @"%d   ", groupCount];
        clientSelected = NO;
    }
    
    [groupSizeButton setTitle: text forState:UIControlStateNormal];   
    
    BOOL inChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];
    if (inChannelMode) {
        if (clientSelected){
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_channel_on"] forState:UIControlStateNormal];
        }
        else {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_channel_off"] forState:UIControlStateNormal];
        }
    } else {
        if (clientSelected){
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_on"] forState:UIControlStateNormal];
        }
        else {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_off"] forState:UIControlStateNormal];
        }
    }
    
    if (groupSelectPopOverController && groupCount > 0) {
        if (groupCount > 1) {
            // NSLog(@"updateGroupButton: setting groupSelectPopOverController size to 320, %i",(groupCount * 44)+20);
            [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, (groupCount * 44)+20) animated:YES];
        }
        else {
            // NSLog(@"updateGroupButton: setting groupSelectPopOverController size to fixed 320,64");
            [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, 64) animated:YES];
        }
    }
    // NSLog(@"updateGroupButton: calling showGroupAndEncryption");
    
    [self showGroupAndEncryption];
}

- (void)showGroupButton
{
	UIBarButtonItem *mainBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupSizeButton];
	navigationItem.rightBarButtonItem = mainBarButtonItem;
    [mainBarButtonItem release];    
}

- (void)updateEncryptionIndicator
{
    if (navigationItem.titleView == nil) {
		return;
	}
	
    if (encryptionButton == nil) {
        encryptionButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [encryptionButton addTarget:self action:@selector(toggleEncryption:) forControlEvents:UIControlEventTouchUpInside];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"]){
            UIImage *buttonImage = [UIImage imageNamed:@"nav_bar_enc_on"];
            encryptionButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
            [encryptionButton setImage:buttonImage forState:UIControlStateNormal];
        }
        else {
            UIImage *buttonImage = [UIImage imageNamed:@"nav_bar_enc_off"];
            encryptionButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
            [encryptionButton setImage:buttonImage forState:UIControlStateNormal];
        }
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"]){
        UIImage *buttonImage = [UIImage imageNamed:@"nav_bar_enc_on"];
        encryptionButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [encryptionButton setImage:buttonImage forState:UIControlStateNormal];
    }
    else {
        UIImage *buttonImage = [UIImage imageNamed:@"nav_bar_enc_off"];
        encryptionButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [encryptionButton setImage:buttonImage forState:UIControlStateNormal];
    }
    
    [self showGroupAndEncryption];
}

- (void)showEncryption
{
    UIBarButtonItem *encryptionBarButtomItem = [[UIBarButtonItem alloc] initWithCustomView:encryptionButton];
    navigationItem.rightBarButtonItem = encryptionBarButtomItem;
    [encryptionBarButtomItem release];
}

- (void)showGroupAndEncryption
{
    if (USES_DEBUG_MESSAGES) {  NSLog(@"showGroupAndEncryption");}
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44,44)];
    //[containerView addSubview:encryptionButton];
    [containerView addSubview:groupSizeButton];
    UIBarButtonItem *encryptionGroupButton = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    self.navigationItem.rightBarButtonItem = encryptionGroupButton;
    [encryptionGroupButton release];
    [containerView release];
}

- (void)encryptionChanged: (NSNotification *)notification
{
    BOOL encrypting = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
    encryptionEnabled = encrypting;
    if (navigationItem.titleView != nil){
        //[self updateEncryptionIndicator];
    }

    desktopView.backgroundStyle = encrypting ? HCDesktopBackgroundStyleLock : HCDesktopBackgroundStylePerforated;
}

- (void)pressedButton: (id)sender
{
    // NSLog(@"pressedButton");

    [statusViewController hideStatus];
    
    if (!groupSelectPopOverController) {
        groupSelectPopOverController = [[UIPopoverController alloc] initWithContentViewController:groupViewController];
        groupSelectPopOverController.popoverContentSize = CGSizeMake(320, 400);
        if ([groupSelectPopOverController respondsToSelector:@selector(setPopoverBackgroundViewClass:)]){
            [groupSelectPopOverController setPopoverBackgroundViewClass:[KSCustomPopoverBackgroundView class]];
        }
        [groupSelectPopOverController setContentViewController:groupViewController];
    }
    

    if ([groupSelectPopOverController isPopoverVisible]) {
        [groupSelectPopOverController dismissPopoverAnimated:YES];
        // [self movePullDownToNormalPosition];
    }
    else {
        int groupsize = groupViewController.group.count;
        // NSLog(@"pressedButton groupsize = %i", groupsize);
        if (groupsize > 0) {
            if (groupsize > 1) {
                [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, ((groupsize * 44)+20))];
            }
            else {
                [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, 64)];
            }
//            NSLog(@"presentPopoverFromBarButtonItem");
            [groupViewController.tableView reloadData];
        }
        else {
            [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, 64)];
        }
        [groupSelectPopOverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [groupViewController showViewAnimated:NO];
        
        // [self stopAutoReceiveAndHidePullDown];

//        CGFloat tabBarHeight = self.tabBar.bounds.size.height;
//        CGRect rect = CGRectMake(0, 0, tabBarHeight, tabBarHeight);
//        [groupSelectPopOverController presentPopoverFromRect:rect inView:tabBar permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
    }
}

- (void)stopAutoReceiveAndHidePullDown
{
    if (self.autoReceiveMode) {
        if (USES_DEBUG_MESSAGES) {  NSLog(@"stopAutoReceiveAndPullDownHide stopAnimating");}
        [self.activityIndi stopAnimating];
        [self movePullDownToHidePosition];
        [self switchAutoReceiveMode:NO];
    }
    else {
        if (USES_DEBUG_MESSAGES) {  NSLog(@"stopAutoReceiveAndPullDownHide stopAnimating 2");}
        [self.activityIndi stopAnimating];
        [self movePullDownToHidePosition];
    }
}


- (void)toggleEncryption:(id)sender
{    
    if (desktopData.count == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"] forKey:@"encryption"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotification *notification = [NSNotification notificationWithName:@"encryptionChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void) showNetworkError:(NSError *)error
{
	[super showNetworkError:error];
	[self updateGroupButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // DesktopView needs to redraw its background
    [desktopView setNeedsDisplay];    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat tabBarHeight = self.tabBar.bounds.size.height;
    CGRect rect;
    BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    if (!isPortrait){
        switch (self.tabBar.selectedItem.tag) {
            case 2: {
                if ([self.tabBar.items count] == 7) {
                    rect = CGRectMake(264, 0, tabBarHeight, tabBarHeight);
                }
                else {
                    rect = CGRectMake(214, 0, tabBarHeight, tabBarHeight);
                }
                break;
            }
            case 5: {
                if ([self.tabBar.items count] == 7) {
                    rect = CGRectMake(595, 0, tabBarHeight, tabBarHeight);
                }
                else {
                    rect = CGRectMake(540, 0, tabBarHeight, tabBarHeight);
                }
                break;
            }
            default: {
                rect = CGRectMake(0, 0, tabBarHeight, tabBarHeight);
            }
        }
        if ([contentPopOverController isPopoverVisible]){
            [contentPopOverController dismissPopoverAnimated:NO];
            [contentPopOverController presentPopoverFromRect:rect inView:tabBar permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
        }
    }
    else {
        switch (self.tabBar.selectedItem.tag) {
            case 2: {
                if ([self.tabBar.items count] == 7){
                    rect = CGRectMake(140, 0, tabBarHeight, tabBarHeight);
                }
                else {
                    rect = CGRectMake(86, 0, tabBarHeight, tabBarHeight);
                }
                break;
            }
            case 5: {
                if ([self.tabBar.items count] == 7){
                    rect = CGRectMake(470, 0, tabBarHeight, tabBarHeight);
                }
                else {
                    rect = CGRectMake(415, 0, tabBarHeight, tabBarHeight);
                }
                break;
            }
            default: {
                rect = CGRectMake(0, 0, tabBarHeight, tabBarHeight);
            }
        }
        if ([contentPopOverController isPopoverVisible]){
            [contentPopOverController dismissPopoverAnimated:NO];
            [contentPopOverController presentPopoverFromRect:rect inView:tabBar permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
        }
    }
    if ([musicPopOverController isPopoverVisible]){
        BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
        if (self.tabBar.items.count == 7){
            if (isPortrait) {
                [musicPopOverController presentPopoverFromRect:CGRectMake(248, 953, 49, 49) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            }
            else {
                [musicPopOverController presentPopoverFromRect:CGRectMake(380, 698, 49, 49) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            }
        }
        else {
        if (isPortrait) {
            [musicPopOverController dismissPopoverAnimated:NO];
            [musicPopOverController presentPopoverFromRect:CGRectMake(198, 953, 49, 49) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
        }
        else {
            [musicPopOverController dismissPopoverAnimated:NO];
            [musicPopOverController presentPopoverFromRect:CGRectMake(325, 698, 49, 49) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
        }
        }
    }
    
    if (isPortrait){
        self.defaultOrigin = CGPointMake(235, 100);
    }
    else {
        self.defaultOrigin = CGPointMake(350, 100);
    }  
    
    BOOL hasEncryption = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
    desktopView.backgroundStyle = hasEncryption ? HCDesktopBackgroundStyleLock : HCDesktopBackgroundStylePerforated;

    [self setProperPullDownBackgroundImage:isPortrait];
    [self setProperSubViewSizes:isPortrait];
    
    // TODO: set proper item position after rotation
//    ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
//
//    CGPoint myOrigin = CGPointMake(desktopView.frame.size.width / 2 - item.contentView.frame.size.width / 2,
//                                   desktopView.frame.size.height / 2 - item.contentView.frame.size.height / 2);
//    
//    item.viewOrigin = myOrigin;    
//
}

- (void)setProperPullDownBackgroundImage:(BOOL) isPortrait {
    NSString * myPullDownBg = nil;
    if (isPortrait){
        myPullDownBg = @"receive-bg-ipad-portrait";
    }
    else {
        myPullDownBg = @"receive-bg-ipad-landscape";
    }
    
    NSString * myRetinaExt = @"";
    
//    bool isRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
//    if (isRetina) {
//        myRetinaExt = @"@2x";
//    }
    
    NSString* myPullDownBgName = [NSString stringWithFormat:@"%@%@%@", myPullDownBg, myRetinaExt, @".png"];
    if (USES_DEBUG_MESSAGES) {  NSLog(@"setting pulldownbg to %@", myPullDownBgName);}
    self.pullDownBackgroundImage.image = [UIImage imageNamed:myPullDownBgName];
    
}

- (void)setProperSubViewSizes:(BOOL) isPortrait {

    CGRect statusRect = statusViewController.view.frame;
    CGRect errorRect = errorViewController.view.frame;
    if (isPortrait){
        statusRect.size.width = 768;
        errorRect.size.width = 768;
    }
    else {
        statusRect.size.width = 1024;
        errorRect.size.width = 1024;
    }
    statusViewController.view.frame = statusRect;
    errorViewController.view.frame = errorRect;
}

- (void)showTextInputVC:(NSNotification *)notification
{
    TextInputViewController *inputVC = (TextInputViewController *)notification.object;
    [inputVC setHoccerViewController:self];
    [inputVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentModalViewController:inputVC animated:YES];
}

- (void)desktopView:(DesktopView *)desktopView wasTouchedWithTouches:(NSSet *)touches {
    
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {

    if (USES_DEBUG_MESSAGES) {  NSLog(@"popoverControllerDidDismissPopover");}
    [self movePullDownToNormalPosition];
    self.tabBar.selectedItem = nil;
}
@end
