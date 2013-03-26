//
//  HoccerViewControllerIPhone.m
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "HoccerViewControllerIPhone.h"
#import "DesktopView.h"
#import "HoccerText.h"
#import "StatusViewController.h"
#import "GroupStatusViewController.h"
#import "SelectContentController.h"
// #import "PullToReceiveViewController.h"
#import "HelpScrollView.h"
#import "HoccerHistoryController.h"
#import "HCHistoryTVC.h"
#import "ItemViewController.h"
#import "DesktopDataSource.h"
#import "SettingViewController.h"
#import "ChannelViewController.h"
#import "HoccingRulesIPhone.h"
#import "GesturesInterpreter.h"
#import "HoccerHoclet.h"
#import "CustomNavigationBar.h"
#import "StatusBarStates.h"
#import "ConnectionStatusViewController.h"
#import "UIBarButtonItem+CustomImageButton.h"
#import "HoccerAppDelegate.h"
#import "HCButtonFactory.h"


@interface HoccerViewControllerIPhone ()

@property (retain) ActionElement* delayedAction;
@property (retain, nonatomic) id <ContentSelectController> activeContentSelectController;

           
- (void)showPopOver:(UIViewController *)popOverView;
- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)showSelectContentView;
- (void)showSettingView;
- (void)showHistoryView;
- (void)removePopOverFromSuperview;
- (void)hidePopOverAnimated:(BOOL) animate;

- (void)showGroupButton;
- (void)showChannelButton;
- (void)updateEncryptionIndicator;
- (void)showEncryption;

@end

@implementation HoccerViewControllerIPhone
@synthesize hoccerHistoryController;
@synthesize historyTVC;
@synthesize delayedAction;
@synthesize auxiliaryView;
@synthesize activeContentSelectController;
@synthesize navigationItem;
//@synthesize scrollView;
//@synthesize refreshScrollView = _refreshScrollView;
@synthesize table = _table;

- (void)viewDidLoad {
	[super viewDidLoad];
    
	hoccingRules = (HoccingRules *)[[HoccingRulesIPhone alloc] init];
	isPopUpDisplayed = FALSE;
	
	navigationItem = [[navigationController visibleViewController].navigationItem retain];
	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar"]] autorelease];
    
	navigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - tabBar.frame.size.height);
	[self.view addSubview:navigationController.view];
    
	self.hoccerHistoryController = [[[HoccerHistoryController alloc] init] autorelease];
	self.hoccerHistoryController.parentNavigationController = navigationController;
	self.hoccerHistoryController.hoccerViewController = self;
	self.hoccerHistoryController.historyData = historyData;
    self.hoccerHistoryController.useEditingButtons = YES;
	
	self.historyTVC = [[[HCHistoryTVC alloc] init] autorelease];
	self.historyTVC.parentNavigationController = navigationController;
	self.historyTVC.hoccerViewController = self;
   
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    desktopViewHeight = 341.0;
    if (screenHeight > 480){
        desktopViewHeight += 91.0;
    }
    
    NSArray *group = groupViewController.group;
    if (group != nil) {
        NSMutableArray *others = [NSMutableArray arrayWithCapacity:[group count]];
        for (NSDictionary *dict in group) {
            if (![[dict objectForKey:@"id"] isEqual:[self.linccer uuid]]) {
                [others addObject:dict];
            }
        }
        [self setDesktopBackgroundImage:others];
    }
    else {
        NSMutableArray *others = [NSMutableArray arrayWithCapacity:0];
        [self setDesktopBackgroundImage:others];
    }
    
    if ([tabBar respondsToSelector:@selector(setSelectedImageTintColor:)]) {
        [tabBar setSelectedImageTintColor:[UIColor lightGrayColor]];
        [tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"tab_bar_active"]];
        NSMutableArray *styledItems = [NSMutableArray arrayWithCapacity:4];
        
        //UITabBarItem *content = [[UITabBarItem alloc] initWithTitle:@"Select Content" image:nil tag:1];
        UITabBarItem *content = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Button_Content", nil) image:nil tag:1];
        [content setFinishedSelectedImage:[UIImage imageNamed:@"tab_bar_content_btn"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_content_btn"]];
        [styledItems addObject:content];
        [content release];
        UITabBarItem *history = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Button_History", nil) image:nil tag:2];
        [history setFinishedSelectedImage:[UIImage imageNamed:@"tab_bar_history_btn"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_history_btn"]];
        [styledItems addObject:history];
        [history release];
        UITabBarItem *channelBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Button_Channel", nil) image:nil tag:3];
        [channelBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_bar_channel_btn"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_channel_btn"]];
        [styledItems addObject:channelBarItem];
        [channelBarItem release];
        UITabBarItem *settings = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Button_Settings", nil) image:nil tag:4];
        [settings setFinishedSelectedImage:[UIImage imageNamed:@"tab_bar_settings_btn"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_settings_btn"]];
        [styledItems addObject:settings];
        [settings release];
        [tabBar setItems:styledItems];
    }

	[desktopView insertSubview:statusViewController.view atIndex:3];
    [statusViewController.view setNeedsLayout];
    
    [desktopView insertSubview:errorViewController.view atIndex:2];
    [errorViewController.view setNeedsLayout];

	[desktopView insertSubview:groupViewController.view atIndex:1];
	groupViewController.largeBackground = [UIImage imageNamed:@"statusbar_small.png"];
	[groupViewController setState:[LocationState state]];
	[groupViewController hideViewAnimated: NO];
    groupViewController.delegate = self;
	
	helpController = [[HelpController alloc] initWithController:navigationController];
	[helpController viewDidLoad];
    
    //[self showPullDown];
    
    self.pullDownView.desktopView = desktopView;
    
    //isPullDown = NO;
    	
    [self updateGroupButton];
    [self updateChannelButton];
    //[self updateEncryptionIndicator];
    
    [self showTabBar:YES];
    [self movePullDownToNormalPosition];
	[self showHud];
}

- (void)viewDidUnload
{
    [self setActivityIndi:nil];
    [self setPullDownBackgroundImage:nil];
    [self setPullDownView:nil];
//    [pull containingViewDidUnload];
}

- (void) dealloc {
	[hoccerHistoryController release];
	[historyTVC release];
	[navigationController release];
	[navigationItem release];
	[tabBar release];
	[auxiliaryView release];
	[delayedAction release];
	[helpController release];
    [groupSizeButton release];
    [activeContentSelectController release];
	
	[super dealloc];
}

- (void)setContentPreview: (HoccerContent *)content {
	[super setContentPreview:content];
    groupSizeButton.hidden = NO;
}

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller {
    self.tabBar.selectedItem = nil;
    self.activeContentSelectController = controller;

    [self hidePopOverAnimated:NO];
    [self presentModalViewController:controller.viewController animated:YES];    
}

- (void)dismissContentSelectViewController {
    self.activeContentSelectController = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectText: (id)sender {    
    self.tabBar.selectedItem = nil;
    [self hidePopOverAnimated:NO];

    [super selectText:sender];
}

- (IBAction)selectPasteboard:(id)sender {
    self.tabBar.selectedItem = nil;
    
    [super selectPasteboard:sender];
    [self hidePopOverAnimated:NO];
}

- (IBAction)selectAutoReceive:(id)sender
{
    if (USES_DEBUG_MESSAGES) {  NSLog(@"#### HoccerViewControllerIPhone selectAutoReceive ####");}
    
    [super selectAutoReceive:sender];

    self.tabBar.selectedItem = nil;
    
    [self hidePopOverAnimated:NO];
}

- (IBAction)selectMyContact:(id)sender
{
    [super selectMyContact:sender];
    self.tabBar.selectedItem = nil;
    [self hidePopOverAnimated:NO];
}

- (IBAction)toggleSettings:(id)sender
{
	if (!isPopUpDisplayed) {
		[self showSettingView];
	}
    else if (auxiliaryView != self.settingViewController) {
		self.delayedAction = [ActionElement actionElementWithTarget:self selector:@selector(showSettingView)];
		[self hidePopOverAnimated:YES];
	}
    else {
		[self hidePopOverAnimated:YES];
		tabBar.selectedItem = nil;
	}
}

- (IBAction)toggleSelectContent:(id)sender
{
	if (!isPopUpDisplayed) {			
		[self showSelectContentView];
	} else if (![auxiliaryView isKindOfClass:[SelectContentController class]]) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showSelectContentView)];
		[self hidePopOverAnimated: YES];
	} else {
		[self hidePopOverAnimated: YES];
		tabBar.selectedItem = nil;
	}
}

- (IBAction)toggleHistory:(id)sender
{
	if (!isPopUpDisplayed) {
		[self showHistoryView];
	}
    else if (![auxiliaryView isKindOfClass:[HoccerHistoryController class]]) {
		self.delayedAction = [ActionElement actionElementWithTarget:self selector:@selector(showHistoryView)];
		[self hidePopOverAnimated: YES];
	}
    else {
		[self hidePopOverAnimated: YES];
		tabBar.selectedItem = nil;
	}

    //new stuff with flip history
    BOOL useFlipHistory = NO;
    
    if (useFlipHistory) {
        if (!isPopUpDisplayed) {
            [self showNewHistoryView];
        }
        else if (![auxiliaryView isKindOfClass:[HCHistoryTVC class]]) {
            self.delayedAction = [ActionElement actionElementWithTarget:self selector:@selector(showNewHistoryView)];
            [self hidePopOverAnimated: YES];
        }
        else {
            [self hidePopOverAnimated: YES];
            tabBar.selectedItem = nil;
        }        
    }
}

- (IBAction)toggleChannel:(id)sender
{
	if (!isPopUpDisplayed) {
		[self showChannelView];
    }
    else if (auxiliaryView != self.channelViewController) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showChannelView)];
		[self hidePopOverAnimated: YES];
	}
    else {
		[self hidePopOverAnimated: YES];
		tabBar.selectedItem = nil;
	}
    //[self updateChannelButton];
}

- (void)showDesktop
{
	[self hidePopOverAnimated:YES];
    tabBar.selectedItem = nil;
}

- (void)showSelectContentView
{
	SelectContentController *selectContentViewController = [[SelectContentController alloc] init];
	selectContentViewController.delegate = self;
	
	[self showPopOver:selectContentViewController];
	[selectContentViewController release];
}

- (void)showSettingView
{
	self.settingViewController.parentNavigationController = navigationController;
	[self showPopOver:self.settingViewController];
	
	navigationItem.title = NSLocalizedString(@"Title_Settings", nil);
    
    UIBarButtonItem *doneButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Done", nil)
                                                                 style:HCBarButtonBlack
                                                                target:self
                                                                action:@selector(cancelPopOver)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [doneButton release];

    navigationItem.titleView = nil;
    navigationItem.leftBarButtonItem = nil;
}


- (void)showHistoryView
{
	[self showPopOver:self.hoccerHistoryController];
	navigationItem.title = NSLocalizedString(@"Title_History", nil);
	navigationItem.titleView = nil;
}

- (void)showNewHistoryView
{
	[self showPopOver:self.historyTVC];
    	
    navigationItem.title = NSLocalizedString(@"Title_History", nil);
	
    UIBarButtonItem *doneButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Done", nil)
                                                                 style:HCBarButtonBlack
                                                                target:self
                                                                action:@selector(cancelPopOver)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [doneButton release];
    
	navigationItem.titleView = nil;
}

- (void)showChannelView
{
	self.channelViewController.parentNavigationController = navigationController;
	[self showPopOver:self.channelViewController];    
    
	navigationItem.title = NSLocalizedString(@"Title_Channel", nil);
	
    UIBarButtonItem *doneButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Done", nil)
                                                                 style:HCBarButtonBlack
                                                                target:self
                                                                action:@selector(cancelPopOver)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [doneButton release];    
    
	navigationItem.titleView = nil;
    navigationItem.leftBarButtonItem = nil;

    self.channelViewController.delegate = self;
}



- (void)showPopOver:(UIViewController *)popOverView
{
    [self stopAutoReceiveAndHidePullDown];

	[popOverView viewWillAppear:YES];
	
	gestureInterpreter.delegate = nil;
	self.auxiliaryView = popOverView;
	
	CGRect popOverFrame = popOverView.view.frame;
	popOverFrame.size = desktopView.frame.size;
	popOverFrame.origin= CGPointMake(0, self.view.frame.size.height);
	popOverView.view.frame = popOverFrame;	
	
	[desktopView insertSubview:popOverView.view atIndex:8];

	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.3];
	
	popOverFrame.origin = CGPointMake(0, 0);
	popOverView.view.frame = popOverFrame;
	[UIView commitAnimations];
	
	isPopUpDisplayed = TRUE;
	
    [groupViewController hideStatus];
	[popOverView viewDidAppear:YES];
}

- (void)showTextInputVC:(NSNotification *)notification
{
    TextInputViewController *inputVC = (TextInputViewController *)notification.object;
    [inputVC setHoccerViewController:self];

    [self showPopOver:inputVC];
        
    UIBarButtonItem *doneButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Done", nil)
                                                                   style:HCBarButtonBlue
                                                                  target:inputVC
                                                                  action:@selector(doneButtonTapped:)];

    
    UIBarButtonItem *cancelButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_Cancel", nil)
                                                                   style:HCBarButtonBlack
                                                                  target:self
                                                                  action:@selector(cancelPopOver)];
    
    [self.navigationItem setRightBarButtonItem:doneButton];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [cancelButton release];
    [doneButton release];
    navigationItem.titleView = nil;
    navigationItem.title = @"";
}

- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
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

- (void)hidePopOverAnimated:(BOOL) animate
{
    if (animate) {
        [self movePullDownToNormalPosition];
    }
    
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
		}
        else {
			self.auxiliaryView.view.frame = selectContentFrame;
			[self removePopOverFromSuperview];
		}
	}
	self.gestureInterpreter.delegate = self;
	
	[navigationController popToRootViewControllerAnimated:YES];
    navigationItem.leftBarButtonItem = nil;

	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];
    
    [self showGroupButton];
    [self showChannelButton];
    //[self updateEncryptionIndicator];
}

#pragma mark -
#pragma mark Linccer Delegate Methods
- (void)linccer:(HCLinccer *)linccer didUpdateGroup:(NSArray *)group
{
    NSMutableArray *others = [NSMutableArray arrayWithCapacity:[group count]];
    for (NSDictionary *dict in group) {
        if (![[dict objectForKey:@"id"] isEqual:[self.linccer uuid]]) {
            [others addObject:dict];            
        }
    }
    
    if (self.tabBar.selectedItem == nil) { // only update when main screen in front
        [self setDesktopBackgroundImage:others];
        
        [groupViewController setGroup: others];
        [self updateGroupButton];
        [self updateChannelButton];
    }
}

- (void)linccer:(HCLinccer *)linncer didReceiveData:(NSArray *)data
{
    [super linccer:linncer didReceiveData:data];
}


- (void)setDesktopBackgroundImage:(NSMutableArray *)others
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
//    BOOL isChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];
    
    CGRect desktopViewRect = desktopView.frame;
    desktopViewRect.origin.y =  0;
    
    if (screenHeight > 480) {
        desktopViewRect.size.height = 455;
    } else {
        desktopViewRect.size.height = 367;
    }
    desktopView.frame = desktopViewRect;

    BOOL hasEncryption = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
    desktopView.backgroundStyle = hasEncryption ? HCDesktopBackgroundStyleLock : HCDesktopBackgroundStylePerforated;
}

- (void)groupStatusViewController:(GroupStatusViewController *)controller didUpdateSelection:(NSArray *)clients
{
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
    [self updateChannelButton];
}

#pragma mark -
#pragma mark TapBar delegate Methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	switch (item.tag) {
		case 1:
			[self toggleSelectContent:self];
			break;
		case 2:
			[self toggleHistory:self];
			break;
		case 3:
			[self toggleChannel:self];
			break;
		case 4:
			[self toggleSettings:self];
			break;
		default:
			//NSLog(@"this should not happen");
			break;
	}
}

- (void)handleError: (NSError *)error {
    [super handleError:error];
    
    if (error != nil && [[error domain] isEqual:NSURLErrorDomain]) {
        [groupViewController setGroup:nil];
        [groupSizeButton setTitle: @"X  " forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark User Actions
- (void)cancelPopOver
{
    if (self.channelViewController != nil) {
        if (self.channelViewController.channelTextField != nil) {
            if (self.channelViewController.channelTextField.text.length > 0) {
                if ([self.channelViewController textFieldShouldReturn: self.channelViewController.channelTextField] == NO) {
                    return;
                }
            }
        }
    }
    
	tabBar.selectedItem = nil;
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:(id)UIInterfaceOrientationPortrait];
    }
	[self hidePopOverAnimated:YES];
    
    [self updateGroupButton];
    [self updateChannelButton];

    NSArray *group = groupViewController.group;
    if (group != nil) {
        NSMutableArray *others = [NSMutableArray arrayWithCapacity:[group count]];
        for (NSDictionary *dict in group) {
            if (![[dict objectForKey:@"id"] isEqual:[self.linccer uuid]]) {
                [others addObject:dict];
            }
        }
        [self setDesktopBackgroundImage:others];
    }
    else {
        NSMutableArray *others = [NSMutableArray arrayWithCapacity:0];
        [self setDesktopBackgroundImage:others];
    }
}

#pragma mark -
#pragma mark Private Methods
- (void)updateGroupButton
{
	if (navigationItem.titleView == nil) {
		return;
	}
    BOOL isChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];

    if (groupSizeButton == nil) {
        groupSizeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [groupSizeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [groupSizeButton addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (isChannelMode) {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_channel_off"] forState:UIControlStateNormal];
        }
        else {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_off"] forState:UIControlStateNormal];
        }
        
        groupSizeButton.frame = CGRectMake(0, 0, 56, 44);
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
    
    [groupSizeButton setTitle:text forState:UIControlStateNormal];
    if (clientSelected) {
        if (isChannelMode) {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_channel_on"] forState:UIControlStateNormal];
        }
        else {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_on"] forState:UIControlStateNormal];
        }
    }
    else {
        if (isChannelMode) {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_channel_off"] forState:UIControlStateNormal];
        }
        else {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_off"] forState:UIControlStateNormal];
        }
    }
    [self showGroupButton];
    [self showChannelButton];
}

- (void)clientChannelChanged:(NSNotification *)notification
{    
    [self updateGroupButton];
    [self updateChannelButton];
    
    [linccer updateEnvironment];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self cancelPopOver];
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)startChannelAutoReceiveMode:(NSNotification *)notification
{
//    NSLog(@"startChannelAutoReceiveMode 2");

    [self switchAutoReceiveMode:YES];

}

- (void)updateChannelButton
{
//    BOOL isChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];
//    NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
//    if (isChannelMode) {
//        NSString *channelStr = [NSString stringWithFormat:@"# %@",channel];
//        [channelSizeButton setTitle:channelStr forState:UIControlStateNormal];
//    }
//    else {
//        [channelSizeButton setTitle:@"" forState:UIControlStateNormal];
//    }

    //UIImage *defaultButton = [[UIImage imageNamed:@"nav_bar_btn_default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];

//    if (self.channelAutoReceiveMode) {
//        [channelSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_switch_in"] forState:UIControlStateNormal];
//    }
//    else {
//        [channelSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_btn_switch_out"] forState:UIControlStateNormal];
//    }    
    [self showChannelButton];
}

- (void)showGroupButton
{
	UIBarButtonItem *mainBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupSizeButton];
	navigationItem.rightBarButtonItem = mainBarButtonItem;
    [mainBarButtonItem release];
}

- (void)showChannelButton
{
    BOOL isChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];
    if (!isChannelMode) {
        navigationItem.leftBarButtonItem = nil;
        return;
    }
    
    UIBarButtonItem *channelButton = [HCButtonFactory newItemWithTitle:NSLocalizedString(@"Button_LeaveChannel", nil)
                                                                    style:HCBarButtonBlackPointingLeft
                                                                   target:self
                                                                   action:@selector(pressedLeaveChannelMode:)];

	navigationItem.leftBarButtonItem = channelButton;
    [channelButton release];
}

- (void)updateEncryptionIndicator{
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
    
    [self showEncryption];
}

- (void)showEncryption
{
    UIBarButtonItem *encryptionBarButtomItem = [[UIBarButtonItem alloc] initWithCustomView:encryptionButton];
    navigationItem.leftBarButtonItem = encryptionBarButtomItem;
    [encryptionBarButtomItem release];
}

- (void)encryptionChanged: (NSNotification *)notification
{
    BOOL encrypting = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
    encryptionEnabled = encrypting;
    for (int i = 0;i < desktopData.numberOfItems; i++){
        [desktopData removeHoccerController:[desktopData hoccerControllerDataAtIndex:i]];
    }
    [desktopView reloadData];
    
    NSArray *group = groupViewController.group;
    if (group != nil) {
        NSMutableArray *others = [NSMutableArray arrayWithCapacity:[group count]];
        for (NSDictionary *dict in group) {
            if (![[dict objectForKey:@"id"] isEqual:[self.linccer uuid]]) {
                [others addObject:dict];
            }
        }
        [self setDesktopBackgroundImage:others];
    }
    else {
        NSMutableArray *others = [NSMutableArray arrayWithCapacity:0];
        [self setDesktopBackgroundImage:others];
    }
    
    if (navigationItem.titleView != nil){
        //[self updateEncryptionIndicator];
    }
}

- (void)desktopView:(DesktopView *)desktopView wasTouchedWithTouches:(NSSet *)touches
{
    [groupViewController hideViewAnimated:NO];
    
    if (!self.autoReceiveMode) {
        [self movePullDownToNormalPosition];
    }
}

- (void)pressedButton:(id)sender
{
    [statusViewController hideStatus];
    
	if (groupViewController.view.hidden == NO) {
		//[groupViewController setLocationHint:nil];
        [groupViewController hideViewAnimated:NO];

        [self movePullDownToNormalPosition];
	}
    else {
		[groupViewController setLocationHint:[HCEnvironmentManager messageForLocationInformation: hoccabilityInfo]];
        [self stopAutoReceiveAndHidePullDown];
        // [groupViewController showViewAnimated:NO];
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

- (void)pressedLeaveChannelMode:(id)sender
{
    BOOL isChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];
    if (isChannelMode) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"channel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotification *notification = [NSNotification notificationWithName:@"clientChannelChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}


- (void)toggleEncryption: (id)sender {
    
    if (desktopData.count == 0){
        [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"] forKey:@"encryption"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
        NSNotification *notification = [NSNotification notificationWithName:@"encryptionChanged" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void) showNetworkError:(NSError *)error {
    [self stopAutoReceiveAndHidePullDown];
	[super showNetworkError:error];
	[self updateGroupButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([self.auxiliaryView isKindOfClass:[TextInputViewController class]]) {
        return YES;
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([self.auxiliaryView isKindOfClass:[TextInputViewController class]]) {
        TextInputViewController *textInputVC = (TextInputViewController *)self.auxiliaryView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)){
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                
                CGRect newFrame = CGRectMake(0, 10, 480, 96);
                textInputVC.textView.frame = newFrame;
                
                [UIView commitAnimations];
            }
            else {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                
                CGRect newFrame = CGRectMake(0, 0, 320, 200);
                textInputVC.textView.frame = newFrame;
                
                [UIView commitAnimations];
            }
        }
    }
}

- (void)ensureViewIsHoccable
{
    [super ensureViewIsHoccable];
    [self ensurePullDownPosition];
}

@end
