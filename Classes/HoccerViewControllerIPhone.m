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
#import "SelectContentViewController.h"
#import "HelpScrollView.h"
#import "HoccerHistoryController.h"
#import "HocItemData.h"
#import "DesktopDataSource.h"

#import "HoccingRulesIPhone.h"
#import "GesturesInterpreter.h"

@interface ActionElement : NSObject
{
	id target;
	SEL selector;
}

+ (ActionElement *)actionElementWithTarget: (id)aTarget selector: (SEL)selector;
- (id)initWithTargat: (id)aTarget selector: (SEL)selector;
- (void)perform;

@end


@implementation ActionElement

+ (ActionElement *)actionElementWithTarget: (id)aTarget selector: (SEL)aSelector {
	return [[[ActionElement alloc] initWithTargat:aTarget selector:aSelector] autorelease];
}

- (id)initWithTargat: (id)aTarget selector: (SEL)aSelector {
	self = [super init];
	if (self != nil) {
		target = aTarget;
		selector = aSelector;	
	}
	
	return self;
}

- (void)perform {
	[target performSelector:selector];
}

@end


@interface HoccerViewControllerIPhone ()

@property (retain) ActionElement* delayedAction;

- (void)showPopOver: (UIViewController *)popOverView;
- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)showSelectContentView;
- (void)showHelpView;
- (void)showHistoryView;
- (void)removePopOverFromSuperview;

@end

@implementation HoccerViewControllerIPhone
@synthesize delayedAction;
@synthesize auxiliaryView;
@synthesize tabBar;


- (void)viewDidLoad {
	[super viewDidLoad];

	hoccingRules = [[HoccingRulesIPhone alloc] init];
	isPopUpDisplayed = FALSE;
	
	navigationController.navigationBar.tintColor = [UIColor blackColor];
	navigationItem = [[navigationController visibleViewController].navigationItem retain];

	navigationController.view.frame = CGRectMake(0, 0, 
												 self.view.frame.size.width, 
												 self.view.frame.size.height - tabBar.frame.size.height); 

	[self.view addSubview:navigationController.view];
	self.hoccerHistoryController.parentNavigationController = navigationController;
	
	[self.view insertSubview:statusViewController.view aboveSubview:navigationController.view];
	
	CGRect statusRect = statusViewController.view.frame;
	statusRect.origin.y = 44;
	statusViewController.view.frame = statusRect;
	statusViewController.view.hidden = YES;
}

- (void) dealloc
{
	[navigationItem release];
	[super dealloc];
}



- (IBAction)selectContacts: (id)sender {
	[self hidePopOverAnimated: YES];
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (IBAction)selectImage: (id)sender {
	[self hidePopOverAnimated: NO];
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}

- (IBAction)selectText: (id)sender {
	[self hidePopOverAnimated: YES];
	
	HoccerContent* content = [[[HoccerText alloc] init] autorelease];
	[self setContentPreview: content];
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
	} else if (![auxiliaryView isKindOfClass:[SelectContentViewController class]]) {
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

- (void)showSelectContentView {
	SelectContentViewController *selectContentViewController = [[SelectContentViewController alloc] init];
	selectContentViewController.delegate = self;
	
	[self showPopOver: selectContentViewController];
	[selectContentViewController release];
	
	navigationItem.title = @"Select";
}

- (void)showHelpView {
	self.helpViewController.delegate = self;
	
	[self showPopOver:self.helpViewController];
	
	navigationItem.title = @"Help";
}

- (void)showHistoryView {
	[self showPopOver: self.hoccerHistoryController];
	
	navigationItem.title = @"History";
}

- (void)showPopOver: (UIViewController *)popOverView  {
	gestureInterpreter.delegate = nil;
	self.auxiliaryView = popOverView;
	
	CGRect selectContentFrame = popOverView.view.frame;
	selectContentFrame.size = desktopView.frame.size;
	selectContentFrame.origin= CGPointMake(0, self.view.frame.size.height);
	popOverView.view.frame = selectContentFrame;	
	
	[desktopView addSubview:popOverView.view];

	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.3];
	
	selectContentFrame.origin = CGPointMake(0,0);
	popOverView.view.frame = selectContentFrame;
	[UIView commitAnimations];
	
	isPopUpDisplayed = TRUE;
	
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																			target:self action:@selector(hidePopOverAnimated:)];
	
	navigationItem.rightBarButtonItem = cancel;
	[cancel release];
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
	[navigationItem setRightBarButtonItem:nil animated:YES];
	navigationItem.title = @"Hoccer";
	tabBar.selectedItem = nil;
}

#pragma mark -
#pragma mark HocDataItem Delegate Methods
- (void)hocItemWasReceived: (HocItemData *)item {
	statusViewController.hocItemData = nil;
	[statusViewController hideActivityInfo];
	
	[hoccerHistoryController addContentToHistory:item];

	[[item content] previewInViewController:navigationController];
	[desktopData removeHocItem:item];
	[desktopView reloadData];
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
			[self toggleHelp:self];
			break;
		default:
			NSLog(@"this should not happen");
			break;
	}
}




@end
