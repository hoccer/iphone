//
//  HoccerViewControlleriPad.m
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
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
#import "HoccingRulesIPad.h"
#import "GesturesInterpreter.h"
#import "HoccerHoclet.h"
#import "CustomNavigationBar.h"

#import "StatusBarStates.h"
#import "ConnectionStatusViewController.h"

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


@end

@implementation HoccerViewControlleriPad
@synthesize hoccerHistoryController;
@synthesize delayedAction;
@synthesize auxiliaryView;
@synthesize tabBar;
@synthesize activeContentSelectController;
@synthesize navigationItem;

- (void)viewDidLoad {
	[super viewDidLoad];
    
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
	
	desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"desktop_ipad.png"]];
	tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bar.png"]];
    
    
	[desktopView insertSubview:statusViewController.view atIndex:0];
    CGRect statusRect = statusViewController.view.frame;
	statusRect = CGRectMake(0, 0, 768, 38);
	statusViewController.view.frame = statusRect;
	
    
    CGRect infoRect = CGRectMake(0, 0, 320, 400);
    infoViewController = [[GroupStatusViewController alloc] init];
	infoViewController.view.frame = infoRect;
	infoViewController.largeBackground = [UIImage imageNamed:@"statusbar_large_hoccability.png"];
	[infoViewController setState:[LocationState state]];
    infoViewController.delegate = self;
	
	helpController = [[HelpController alloc] initWithController:navigationController];
	[helpController viewDidLoad];
	
	[self showHud];
    [self updateGroupButton];
    [self updateEncryptionIndicator];
    
    CGRect historySettingsRect = CGRectMake(0, 0, 150, 35);
    NSArray *histSetItems = [NSArray arrayWithObjects:[UIImage imageNamed:@"navbar_btn_history_ipad"],[UIImage imageNamed:@"navbar_btn_settings_ipad"],nil];
    historySettings = [[UISegmentedControl alloc]initWithItems:histSetItems];
    historySettings.segmentedControlStyle = UISegmentedControlStyleBar;
    historySettings.tintColor = [UIColor clearColor];
    historySettings.momentary = YES;
    historySettings.backgroundColor = [UIColor clearColor];
    [historySettings addTarget:self action:@selector(historySettingsAction:) forControlEvents:UIControlEventValueChanged];
    [historySettings setFrame:historySettingsRect];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithCustomView:historySettings];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    [historySettings release];
    [leftButton release];
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSMutableArray *modifyMe = [[tabBar items] mutableCopy];
        [modifyMe removeObjectAtIndex:0];
        NSArray *newItems = [[NSArray alloc] initWithArray:modifyMe];
        [tabBar setItems:newItems animated:NO];
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
}

- (IBAction)toggleHelp: (id)sender {
    if (!settingsPopOverNavigationController) {
        settingsPopOverNavigationController = [[UINavigationController alloc]initWithRootViewController:self.helpViewController];
        self.helpViewController.parentNavigationController = settingsPopOverNavigationController;
        [settingsPopOverNavigationController setTitle:@"Settings"];
    }
    if (!settingsPopOverController) {
        settingsPopOverController = [[UIPopoverController alloc]initWithContentViewController:settingsPopOverNavigationController];
        [settingsPopOverController setPopoverContentSize:CGSizeMake(320, 400)];
    }
    if ([settingsPopOverController isPopoverVisible]){
        [settingsPopOverController dismissPopoverAnimated:YES];
    }
    else {
        [settingsPopOverController presentPopoverFromRect:CGRectMake(97, 0, 50, 44) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];        
        [historyPopOverController dismissPopoverAnimated:NO];
    }
}

- (IBAction)toggleHistory: (id)sender {
	
    if (!historyPopOverNavigationController) {
        historyPopOverNavigationController = [[UINavigationController alloc]initWithRootViewController:self.hoccerHistoryController];
        self.hoccerHistoryController.parentNavigationController = historyPopOverNavigationController;
        [historyPopOverNavigationController setTitle:@"History"];
    }
    if (!historyPopOverController) {
        historyPopOverController = [[UIPopoverController alloc]initWithContentViewController:historyPopOverNavigationController];
        [historyPopOverController setPopoverContentSize:CGSizeMake(320, 400)];
    }
    if ([historyPopOverController isPopoverVisible]){
        [historyPopOverController dismissPopoverAnimated:YES];
    }
    else {
        [historyPopOverController presentPopoverFromRect:CGRectMake(20, 0, 50, 44) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];        
        [settingsPopOverController dismissPopoverAnimated:NO];

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

- (IBAction)historySettingsAction:(id)sender{
    
    int selectedIndex = [historySettings selectedSegmentIndex];
    
    switch (selectedIndex) {
        case 0:
            [self toggleHistory:nil];
            break;
        case 1:
            [self toggleHelp:nil];
            break;
        default:
            break;
    }
    
}


- (void)showDesktop {
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
	
    [infoViewController hideStatus];
	[popOverView viewDidAppear:YES];
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
	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];
    
    [self showGroupAndEncryption];
    //navigationItem.leftBarButtonItem = nil;
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
    
    [infoViewController setGroup: others];
    
    
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
			NSLog(@"this should not happen");
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
	[self hidePopOverAnimated:YES];
}


#pragma mark -
#pragma mark Private Methods
- (void)updateGroupButton {
	if (navigationItem.titleView == nil) {
		return;
	}
	
    if (groupSizeButton == nil) {
        groupSizeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [groupSizeButton addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
        groupSizeButton.frame = CGRectMake(80, -6, 36, 52);
    }
    
    NSInteger groupCount = [[infoViewController group] count];
    NSString *text = nil;
    if (groupCount < 1) {
        text = @"0";
        clientSelected = NO;
        if (groupSelectPopOverController){
            [groupSelectPopOverController dismissPopoverAnimated:YES];
        }
    } else if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"selected_clients"] count] > 0) {
        text = [NSString stringWithFormat: @"%d✓", [[[NSUserDefaults standardUserDefaults] arrayForKey:@"selected_clients"]  count]];
        clientSelected = YES;
    } else {
        text = [NSString stringWithFormat: @"%d", groupCount];
        clientSelected = NO;
    }
    
    [groupSizeButton setTitle: text forState:UIControlStateNormal];   
    
    if (groupSelectPopOverController && groupCount > 0){
        if (groupCount > 1)
            [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, ((groupCount * 44)+20)) animated:YES];
        else
            [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, 63) animated:YES];
    }
    
    [self showGroupAndEncryption];
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
    
    [self showGroupAndEncryption];
}

- (void)showEncryption{
    UIBarButtonItem *encryptionBarButtomItem = [[UIBarButtonItem alloc] initWithCustomView:encryptionButton];
    navigationItem.rightBarButtonItem = encryptionBarButtomItem;
    [encryptionBarButtomItem release];
    
}
- (void)showGroupAndEncryption {
    
    
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (encryptionButton.frame.size.width*2)+40, encryptionButton.frame.size.height)];
    [containerView addSubview:encryptionButton];
    [containerView addSubview:groupSizeButton];
    UIBarButtonItem *encryptionGroupButton = [[UIBarButtonItem alloc]initWithCustomView:containerView];
    self.navigationItem.rightBarButtonItem = encryptionGroupButton;
    [encryptionGroupButton release];
    [containerView release];
}
- (void)encryptionChanged: (NSNotification *)notification {
    BOOL encrypting = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
    encryptionEnabled = encrypting;
    if (navigationItem.titleView != nil){
        [self updateEncryptionIndicator];
    }
}




- (void)pressedButton: (id)sender {	
    [statusViewController hideStatus];
    if (!groupSelectPopOverController){
        groupSelectPopOverController = [[UIPopoverController alloc]initWithContentViewController:infoViewController];
        groupSelectPopOverController.popoverContentSize = CGSizeMake(320, 400);
    }
    if ([groupSelectPopOverController isPopoverVisible]){
        [groupSelectPopOverController dismissPopoverAnimated:YES];
    }
    else {
        int groupsize = infoViewController.group.count;
        if (groupsize > 0){
        [groupSelectPopOverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            if (groupsize > 1){
                [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, ((groupsize * 44)+20))];
            }
            else {
                [groupSelectPopOverController setPopoverContentSize:CGSizeMake(320, 64)];
            }
        }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    CGFloat tabBarHeight = self.tabBar.bounds.size.height;
    CGRect rect;
    BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
    if (!isPortrait){
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

}



-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.tabBar.selectedItem = nil;
}
@end
