//
//  HoccerViewControllerIPhone.m
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
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
#import "HoccingRulesIPhone.h"
#import "GesturesInterpreter.h"
#import "HoccerHoclet.h"
#import "CustomNavigationBar.h"
#import "StatusBarStates.h"
#import "ConnectionStatusViewController.h"



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
- (void)showEncryptionAndGroup;


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
	
	navigationController.navigationBar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hoccer_bar.png"]];
	
	navigationItem = [[navigationController visibleViewController].navigationItem retain];
	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];

	navigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 
												 self.view.frame.size.height - tabBar.frame.size.height); 

	[self.view addSubview:navigationController.view];
	
    navigationController.delegate = self;
    
	self.hoccerHistoryController = [[[HoccerHistoryController alloc] init] autorelease];
	self.hoccerHistoryController.parentNavigationController = navigationController;
	self.hoccerHistoryController.hoccerViewController = self;
	self.hoccerHistoryController.historyData = historyData;
	
	desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg.png"]];
	//tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bar.png"]];

	[desktopView insertSubview:statusViewController.view atIndex:0];
    CGRect statusRect = statusViewController.view.frame;
	statusRect.origin.y = desktopView.frame.origin.y-19;
	statusViewController.view.frame = statusRect;
	
	[desktopView insertSubview:infoViewController.view atIndex:0];
	infoViewController.view.frame = statusRect;
	infoViewController.largeBackground = [UIImage imageNamed:@"statusbar_large_hoccability.png"];
	[infoViewController setState:[LocationState state]];
	[infoViewController hideViewAnimated: NO];
    infoViewController.delegate = self;
	
	helpController = [[HelpController alloc] initWithController:navigationController];
	[helpController viewDidLoad];
	
	[self showHud];
    [self updateGroupButton];
    [self updateEncryptionIndicator];

}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"viewControllerWillAppear" object:nil];
    
    if([navigationController.viewControllers count ] > 1) {
        UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0,0,85,44)];
        UIButton *myBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [myBackButton setFrame:CGRectMake(0,0,85,44)];
        [myBackButton setImage:[UIImage imageNamed:@"settings_nav_bar_back"] forState:UIControlStateNormal];
        [myBackButton setEnabled:YES];
        [myBackButton addTarget:viewController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        [backButtonView addSubview:myBackButton];
        [myBackButton release];
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
        viewController.navigationItem.leftBarButtonItem = backButton;
        [backButtonView release];
        [backButton release];
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
	
	[super dealloc];
}

- (void)setContentPreview: (HoccerContent *)content {
	[super setContentPreview:content];
    groupSizeButton.hidden = NO;
}

- (void)presentContentSelectViewController: (id <ContentSelectController>)controller {
    self.activeContentSelectController = controller;

    [self hidePopOverAnimated:  NO];
    [self presentModalViewController:controller.viewController animated:YES];    
}

- (void)dismissContentSelectViewController {
    self.activeContentSelectController = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectText: (id)sender {    

    [super selectText:sender];
    [self hidePopOverAnimated:  NO];
}

- (IBAction)selectPasteboard: (id)sender {    
    
    [super selectPasteboard:sender];
    [self hidePopOverAnimated:  NO];
}

- (IBAction)toggleHelp: (id)sender {
	if (!isPopUpDisplayed) {			
		[self showHelpView];
	} else if (auxiliaryView != self.helpViewController) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showHelpView)];
		[self hidePopOverAnimated: YES];
        [self resetTabBar];
	} else {
		[self hidePopOverAnimated: YES];
        [self performSelector:@selector(resetTabBar) withObject:nil afterDelay:0.1];
	}
}

- (IBAction)toggleSelectContent: (id)sender {
	if (!isPopUpDisplayed) {			
		[self showSelectContentView];
	} else if (![auxiliaryView isKindOfClass:[SelectContentController class]]) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showSelectContentView)];
		[self hidePopOverAnimated: YES];
        [self resetTabBar];
	} else {
		[self hidePopOverAnimated: YES];
        [self performSelector:@selector(resetTabBar) withObject:nil afterDelay:0.1];
	}
}

- (IBAction)toggleHistory: (id)sender {
	if (!isPopUpDisplayed) {			
		[self showHistoryView];
	} else if (![auxiliaryView isKindOfClass:[HoccerHistoryController class]]) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showHistoryView)];
		[self hidePopOverAnimated: YES];
        [self resetTabBar];

	} else {
		[self hidePopOverAnimated: YES];
        [self performSelector:@selector(resetTabBar) withObject:nil afterDelay:0.1];
	}
}

- (void)showDesktop {
	[self hidePopOverAnimated:YES];
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
	
    navigationItem.title = @" ";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"history_nav_bar_done"] forState:UIControlStateNormal];
    button.frame=CGRectMake(0.0, 100.0, 85.0, 51.0);
    [button addTarget:self action:@selector(cancelPopOver) forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:button];
	navigationItem.rightBarButtonItem = cancel;
	[cancel release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"settings_nav_bar_back"] forState:UIControlStateNormal];
    backButton.frame=CGRectMake(0, 0, 85, 44);
    navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    [backButton release];

	navigationItem.titleView = nil;
    navigationItem.leftBarButtonItem = nil;
}

- (void)showHistoryView {
	[self showPopOver: self.hoccerHistoryController];
	
	navigationItem.title = NSLocalizedString(@" ", nil);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"history_nav_bar_done"] forState:UIControlStateNormal];
    button.frame=CGRectMake(0.0, 100.0, 85.0, 51.0);
    [button addTarget:self action:@selector(cancelPopOver) forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:button];
	navigationItem.rightBarButtonItem = cancel;
	[cancel release];
    
    UIButton *buttonEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonEdit setBackgroundImage:[UIImage imageNamed:@"history_nav_bar_edit"] forState:UIControlStateNormal];
    buttonEdit.frame=CGRectMake(0.0, 100.0, 85.0, 51.0);
    [buttonEdit addTarget:self.hoccerHistoryController action:@selector(enterCustomEditMode:) forControlEvents:UIControlEventTouchUpInside];

    
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithCustomView:buttonEdit];
	navigationItem.leftBarButtonItem = delete;
	[delete release];

	navigationItem.titleView = nil;
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
    navigationItem.leftBarButtonItem = nil;
	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];
    [self performSelector:@selector(resetTabBar) withObject:nil afterDelay:0.1];
    
    [self showEncryptionAndGroup];
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

-(IBAction) tabBarButtonPressed:(id)sender {
    
    UIButton *theButton = [sender retain]  ;
    switch (theButton.tag) {
		case 1:
			[self toggleSelectContent:self];
            [contentSelectButton setImage:[UIImage imageNamed:@"tab_bar_content_btn_over"] forState:UIControlStateNormal];
            break;
		case 2:
			[self toggleHistory:self];
            [historySelectButton setImage:[UIImage imageNamed:@"tab_bar_history_btn_over"] forState:UIControlStateNormal];
			break;
		case 3:
			[self toggleHelp:self];
            [settingsSelectButton setImage:[UIImage imageNamed:@"tab_bar_settings_btn_over"] forState:UIControlStateNormal];
            break;
		default:
			NSLog(@"this should not happen");
			break;
	}
    [theButton release];
}

-(void)resetTabBar {
    
    [contentSelectButton setImage:[UIImage imageNamed:@"tab_bar_content_btn"] forState:UIControlStateNormal];
    [historySelectButton setImage:[UIImage imageNamed:@"tab_bar_history_btn"] forState:UIControlStateNormal];
    [settingsSelectButton setImage:[UIImage imageNamed:@"tab_bar_settings_btn"] forState:UIControlStateNormal];

    
}


- (void)handleError: (NSError *)error {
    [super handleError:error];
    
    if (error != nil && [[error domain] isEqual:NSURLErrorDomain]) {
        [groupSizeButton setTitle: @"--" forState:UIControlStateNormal];
        [infoViewController setGroup:nil];
    }
    [self resetTabBar];

}

#pragma mark -
#pragma mark User Actions
- (IBAction)cancelPopOver {
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
        groupSizeButton.frame = CGRectMake(44, 0, 44, 44);
        [groupSizeButton setTitleColor:[UIColor colorWithWhite:0.1 alpha:1.0] forState:UIControlStateNormal];
        [groupSizeButton.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:24]];
        [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_status_off"] forState:UIControlStateNormal];
        [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_status_off_over"] forState:UIControlStateHighlighted];
        groupSizeButton.showsTouchWhenHighlighted = NO;
    }
    
    NSInteger groupCount = [[infoViewController group] count];
    NSString *text = nil;
    if (groupCount < 1) {
        text = @"0";
        clientSelected = NO;
    } else if ([[[NSUserDefaults standardUserDefaults] arrayForKey:@"selected_clients"] count] > 0) {
        text = [NSString stringWithFormat: @"%d", [[[NSUserDefaults standardUserDefaults] arrayForKey:@"selected_clients"]  count]];
        [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_status_on"] forState:UIControlStateNormal];
        [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_status_on_over"] forState:UIControlStateHighlighted];
        clientSelected = YES;
    } else {
        text = [NSString stringWithFormat: @"%d", groupCount];
        [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_status_off"] forState:UIControlStateNormal];
        [groupSizeButton setBackgroundImage:[UIImage imageNamed:@"nav_bar_status_off_over"] forState:UIControlStateHighlighted];
        clientSelected = NO;
    }
    
    [groupSizeButton setTitle: text forState:UIControlStateNormal];

    [self showEncryptionAndGroup];
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
            UIImage *buttonImageOver = [UIImage imageNamed:@"nav_bar_enc_on_over"];
            encryptionButton.frame = CGRectMake(0, 0, 44, 44);
            [encryptionButton setImage:buttonImage forState:UIControlStateNormal];
            [encryptionButton setImage:buttonImageOver forState:UIControlStateHighlighted];
        }
        else {
            UIImage *buttonImage = [UIImage imageNamed:@"nav_bar_enc_off"];
            UIImage *buttonImageOver = [UIImage imageNamed:@"nav_bar_enc_off_over"];
            encryptionButton.frame = CGRectMake(0, 0, 44, 44 );
            [encryptionButton setImage:buttonImage forState:UIControlStateNormal];
            [encryptionButton setImage:buttonImageOver forState:UIControlStateHighlighted];
        }

    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"]){
        UIImage *buttonImage = [UIImage imageNamed:@"nav_bar_enc_on"];
        UIImage *buttonImageOver = [UIImage imageNamed:@"nav_bar_enc_on_over"];
        [encryptionButton setImage:buttonImage forState:UIControlStateNormal];
        [encryptionButton setImage:buttonImageOver forState:UIControlStateHighlighted];
    }
    else {
        UIImage *buttonImage = [UIImage imageNamed:@"nav_bar_enc_off"];
        UIImage *buttonImageOver = [UIImage imageNamed:@"nav_bar_enc_off_over"];
        [encryptionButton setImage:buttonImage forState:UIControlStateNormal];
        [encryptionButton setImage:buttonImageOver forState:UIControlStateHighlighted];
    }
    
    [self showEncryptionAndGroup];
}

- (void)showEncryption{
    UIBarButtonItem *encryptionBarButtomItem = [[UIBarButtonItem alloc] initWithCustomView:encryptionButton];
    navigationItem.leftBarButtonItem = encryptionBarButtomItem;
    [encryptionBarButtomItem release];
}

- (void)showEncryptionAndGroup{
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 88, 44)];
    [containerView addSubview:encryptionButton];
    [containerView addSubview:groupSizeButton];
    UIBarButtonItem *encryptionBarButtomItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    navigationItem.rightBarButtonItem = encryptionBarButtomItem;
    [encryptionBarButtomItem release];
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

@end
