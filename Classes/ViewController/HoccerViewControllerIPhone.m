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
#import "HelpScrollView.h"
#import "HoccerHistoryController.h"
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


@interface HoccerViewControllerIPhone ()

@property (retain) ActionElement* delayedAction;
@property (retain, nonatomic) id <ContentSelectController> activeContentSelectController;

           
- (void)showPopOver: (UIViewController *)popOverView;
- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)showSelectContentView;
- (void)showHelpView;
- (void)showHistoryView;
- (void)removePopOverFromSuperview;
- (void)hidePopOverAnimated: (BOOL) animate;
- (void)updateGroupButton;
- (void)showGroupButton;
- (void)updateEncryptionIndicator;
- (void)showEncryption;


@end

@implementation HoccerViewControllerIPhone
@synthesize hoccerHistoryController;
@synthesize delayedAction;
@synthesize auxiliaryView;
@synthesize tabBar;
@synthesize activeContentSelectController;
@synthesize navigationItem;

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
	
   
    NSArray *group = infoViewController.group;
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
    
    if ([tabBar respondsToSelector:@selector(setSelectedImageTintColor:)]){
        [tabBar setSelectedImageTintColor:[UIColor lightGrayColor]];
        [tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"tab_bar_active"]];
        NSMutableArray *styledItems = [NSMutableArray arrayWithCapacity:4];
        
        //UITabBarItem *content = [[UITabBarItem alloc] initWithTitle:@"Select Content" image:nil tag:1];
        UITabBarItem *content = [[UITabBarItem alloc] initWithTitle:@"Content" image:nil tag:1];
        [content setFinishedSelectedImage:[UIImage imageNamed:@"tab_bar_content_btn"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_content_btn"]];
        [styledItems addObject:content];
        [content release];
        UITabBarItem *history = [[UITabBarItem alloc] initWithTitle:@"History" image:nil tag:2];
        [history setFinishedSelectedImage:[UIImage imageNamed:@"tab_bar_history_btn"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_history_btn"]];
        [styledItems addObject:history];
        [history release];
        UITabBarItem *channel = [[UITabBarItem alloc] initWithTitle:@"Channel" image:nil tag:3];
        [channel setFinishedSelectedImage:[UIImage imageNamed:@"tab_bar_channel_btn"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_channel_btn"]];
        [styledItems addObject:channel];
        [channel release];
        UITabBarItem *settings = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:4];
        [settings setFinishedSelectedImage:[UIImage imageNamed:@"tab_bar_settings_btn"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_settings_btn"]];
        [styledItems addObject:settings];
        [settings release];
        [tabBar setItems:styledItems];
    }
    

	[desktopView insertSubview:statusViewController.view atIndex:2];
    CGRect statusRect = statusViewController.view.frame;
	statusRect.origin.y = desktopView.frame.origin.y-19;
	statusViewController.view.frame = statusRect;
    
    [desktopView insertSubview:errorViewController.view atIndex:1];
    CGRect errorRect = errorViewController.view.frame;
    errorRect.origin.y = desktopView.frame.origin.y-19;
	errorViewController.view.frame = errorRect;

	
	[desktopView insertSubview:infoViewController.view atIndex:0];
	infoViewController.view.frame = statusRect;
	infoViewController.largeBackground = [UIImage imageNamed:@"statusbar_small.png"];
	[infoViewController setState:[LocationState state]];
	[infoViewController hideViewAnimated: NO];
    infoViewController.delegate = self;
	
	helpController = [[HelpController alloc] initWithController:navigationController];
	[helpController viewDidLoad];
	
	[self showHud];
    [self updateGroupButton];
    //[self updateEncryptionIndicator];
    
    tabBar.userInteractionEnabled = YES;
    [self.view bringSubviewToFront:tabBar];
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
	
	[super dealloc];
}

- (void)setContentPreview: (HoccerContent *)content {
	[super setContentPreview:content];
    groupSizeButton.hidden = NO;
}

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller {
    self.tabBar.selectedItem = nil;
    self.activeContentSelectController = controller;

    [self hidePopOverAnimated:  NO];
    [self presentModalViewController:controller.viewController animated:YES];    
}

- (void)dismissContentSelectViewController {
    self.activeContentSelectController = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectText: (id)sender {    
    self.tabBar.selectedItem = nil;
    [self hidePopOverAnimated:  NO];

    [super selectText:sender];
}

- (IBAction)selectPasteboard: (id)sender {    
    self.tabBar.selectedItem = nil;
    
    [super selectPasteboard:sender];
    [self hidePopOverAnimated:  NO];
}

- (IBAction)selectMyContact:(id)sender {
    [super selectMyContact:sender];
    self.tabBar.selectedItem = nil;
    [self hidePopOverAnimated:NO];
}
- (IBAction)toggleHelp: (id)sender {
	if (!isPopUpDisplayed) {			
		[self showHelpView];
	} else if (auxiliaryView != self.helpViewController) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showHelpView)];
		[self hidePopOverAnimated: YES];
	} else {
		[self hidePopOverAnimated: YES];
		tabBar.selectedItem = nil;
	}
}

- (IBAction)toggleSelectContent: (id)sender {
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

- (IBAction)toggleHistory: (id)sender {
	if (!isPopUpDisplayed) {
		[self showHistoryView];
	} else if (![auxiliaryView isKindOfClass:[HoccerHistoryController class]]) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showHistoryView)];
		[self hidePopOverAnimated: YES];
	} else {
		[self hidePopOverAnimated: YES];
		tabBar.selectedItem = nil;
	}
}

- (IBAction)toggleChannel: (id)sender {
	if (!isPopUpDisplayed) {
		[self showChannelView];
    } else if (auxiliaryView != self.channelViewController) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showChannelView)];
		[self hidePopOverAnimated: YES];
	} else {
		[self hidePopOverAnimated: YES];
		tabBar.selectedItem = nil;
	}
}

- (void)showDesktop {
	[self hidePopOverAnimated:YES];
    tabBar.selectedItem = nil;
}


- (void)showSelectContentView {
	SelectContentController *selectContentViewController = [[SelectContentController alloc] init];
	selectContentViewController.delegate = self;
	
	[self showPopOver: selectContentViewController];
	[selectContentViewController release];
}

- (void)showHelpView {
	self.helpViewController.parentNavigationController = navigationController;
	[self showPopOver:self.helpViewController];
	
	navigationItem.title = NSLocalizedString(@"Settings", nil);
	UIBarButtonItem *doneButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"nav_bar_btn_done"] target:self action:@selector(cancelPopOver)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [doneButton release];
	navigationItem.titleView = nil;
    navigationItem.leftBarButtonItem = nil;
}

- (void)showHistoryView {
	[self showPopOver: self.hoccerHistoryController];
	
	navigationItem.title = NSLocalizedString(@"History", nil);
	
        UIBarButtonItem *doneButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"nav_bar_btn_done"] target:self action:@selector(cancelPopOver)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [doneButton release];
    
    UIBarButtonItem *editButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"nav_bar_btn_edit"] target:self.hoccerHistoryController action:@selector(enterCustomEditMode:)];
    [self.navigationItem setLeftBarButtonItem:editButton];
    [editButton release];
    
    
	navigationItem.titleView = nil;
}

- (void)showChannelView {
	self.channelViewController.parentNavigationController = navigationController;
	[self showPopOver:self.channelViewController];
	
	navigationItem.title = NSLocalizedString(@"Channel", nil);
	UIBarButtonItem *doneButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"nav_bar_btn_done"] target:self action:@selector(cancelPopOver)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [doneButton release];
	navigationItem.titleView = nil;
    navigationItem.leftBarButtonItem = nil;

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
	
    [infoViewController hideStatus];
	[popOverView viewDidAppear:YES];
}

- (void)showTextInputVC:(NSNotification *)notification {
    TextInputViewController *inputVC = (TextInputViewController *)notification.object;
    [self showPopOver:inputVC];
    UIBarButtonItem *doneButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"nav_bar_btn_done_blue"] target:inputVC action:@selector(doneButtonTapped:)];
    UIBarButtonItem *canelButton = [UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"nav_bar_btn_cancel"] target:self action:@selector(cancelPopOver)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [self.navigationItem setLeftBarButtonItem:canelButton];
    [canelButton release];
    [doneButton release];
    navigationItem.titleView = nil;
    navigationItem.title = @"";
}
- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	[self removePopOverFromSuperview];
}

- (void)removePopOverFromSuperview {

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
    navigationItem.leftBarButtonItem = nil;

	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];
    
    [self showGroupButton];
    //[self updateEncryptionIndicator];
}

#pragma mark -
#pragma mark Linccer Delegate Methods
- (void)linccer:(HCLinccer *)linccer didUpdateGroup:(NSArray *)group {
    
    NSMutableArray *others = [NSMutableArray arrayWithCapacity:[group count]];
    for (NSDictionary *dict in group) {
        if (![[dict objectForKey:@"id"] isEqual:[self.linccer uuid]]) {
            [others addObject:dict];            
        }
    }
    [self setDesktopBackgroundImage:others];
    
    [infoViewController setGroup: others];
    [self updateGroupButton];
}

- (void)setDesktopBackgroundImage:(NSMutableArray *)others
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (others.count == 0) {
        if (screenHeight > 480){
            NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
            if ((channel != nil) && (channel.length > 0)) {
                desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg_alone_channel-568h"]];
            }
            else {
                desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg_alone-568h"]];
            }
        }
        else {
            NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
            if ((channel != nil) && (channel.length > 0)) {
                desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg_alone_channel"]];
            }
            else {
                desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg_alone"]];
            }
        }
    }
    else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"]){
            if (screenHeight > 480){
                desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg_encrypted-568h"]];
            }
            else {
                desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg_encrypted"]];
            }
        }
        else {
            if (screenHeight > 480){
                desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg-568h"]];
            }
            else {
                desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg"]];
            }
        }
    }
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
			[self toggleHelp:self];
			break;
		default:
			//NSLog(@"this should not happen");
			break;
	}
}

- (void)handleError: (NSError *)error {
    [super handleError:error];
    
    if (error != nil && [[error domain] isEqual:NSURLErrorDomain]) {
        [groupSizeButton setTitle: @"--" forState:UIControlStateNormal];
        [infoViewController setGroup:nil];
    }
}

#pragma mark -
#pragma mark User Actions
- (IBAction)cancelPopOver {
	tabBar.selectedItem = nil;
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:(id)UIInterfaceOrientationPortrait];
    }
	[self hidePopOverAnimated:YES];
    
    // RALPH : channel
    [self updateGroupButton];

    NSArray *group = infoViewController.group;
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
- (void)updateGroupButton {
	if (navigationItem.titleView == nil) {
		return;
	}
	
    if (groupSizeButton == nil) {
        groupSizeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [groupSizeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [groupSizeButton addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // RALPH : channel
        NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
        if ((channel != nil) && (channel.length > 0)) {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_red_off"] forState:UIControlStateNormal];
        }
        else {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_off"] forState:UIControlStateNormal];
        }
        
        groupSizeButton.frame = CGRectMake(0, 0, 56, 44);
    }
    
    NSInteger groupCount = [[infoViewController group] count];
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
    if (clientSelected) {
        // RALPH : channel
        NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
        if ((channel != nil) && (channel.length > 0)) {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_red_on"] forState:UIControlStateNormal];
        }
        else {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_on"] forState:UIControlStateNormal];
        }
    }
    else {
        // RALPH : channel
        NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
        if ((channel != nil) && (channel.length > 0)) {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_red_off"] forState:UIControlStateNormal];
        }
        else {
            [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_location_off"] forState:UIControlStateNormal];
        }
    }
    [self showGroupButton];
}

- (void)showGroupButton {
	UIBarButtonItem *hoccabilityBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupSizeButton];
	navigationItem.rightBarButtonItem = hoccabilityBarButtonItem;
    [hoccabilityBarButtonItem release];    
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

- (void)showEncryption{
    UIBarButtonItem *encryptionBarButtomItem = [[UIBarButtonItem alloc] initWithCustomView:encryptionButton];
    navigationItem.leftBarButtonItem = encryptionBarButtomItem;
    [encryptionBarButtomItem release];
}

- (void)encryptionChanged: (NSNotification *)notification {
    BOOL encrypting = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
    encryptionEnabled = encrypting;
    for (int i = 0;i < desktopData.numberOfItems; i++){
        [desktopData removeHoccerController:[desktopData hoccerControllerDataAtIndex:i]];
    }
    [desktopView reloadData];
    
    NSArray *group = infoViewController.group;
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


- (void)desktopView:(DesktopView *)desktopView wasTouchedWithTouches:(NSSet *)touches {
    [infoViewController hideViewAnimated:YES];
}

- (void)pressedButton: (id)sender {	
    [statusViewController hideStatus];
	if (infoViewController.view.hidden == NO) {
		[infoViewController setLocationHint:nil];
	} else {
		[infoViewController setLocationHint: [HCEnvironmentManager messageForLocationInformation: hoccabilityInfo]];
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

@end
