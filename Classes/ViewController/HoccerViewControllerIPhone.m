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
#import "SelectContentController.h"
#import "HelpScrollView.h"
#import "HoccerHistoryController.h"
#import "ItemViewController.h"
#import "DesktopDataSource.h"
#import "SettingViewController.h"
#import "HoccingRulesIPhone.h"
#import "GesturesInterpreter.h"

#import "StatusBarStates.h"
#import "ConnectionStatusViewController.h"

#import "NSFileManager+FileHelper.h"
#import "HCLinccer.h"

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

@interface CustomNavigationBar : UINavigationBar
{}
@end

@implementation CustomNavigationBar

- (void)drawRect: (CGRect)dirtyRect {
	UIImage *image = [UIImage imageNamed: @"hoccer_bar.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
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
- (void)hidePopOverAnimated: (BOOL) animate;
- (void)setHoccabilityButton: (NSInteger)theHoccability;

@end

@implementation HoccerViewControllerIPhone
@synthesize hoccerHistoryController;
@synthesize delayedAction;
@synthesize auxiliaryView;
@synthesize tabBar;

- (void)viewDidLoad {
	[super viewDidLoad];

	hoccingRules = [[HoccingRulesIPhone alloc] init];
	isPopUpDisplayed = FALSE;
	
	navigationController.navigationBar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hoccer_bar.png"]];
	
	navigationItem = [[navigationController visibleViewController].navigationItem retain];
	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];
	[self setHoccabilityButton: 0];

	
	navigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 
												 self.view.frame.size.height - tabBar.frame.size.height); 

	[self.view addSubview:navigationController.view];
	
	self.hoccerHistoryController = [[HoccerHistoryController alloc] init];
	self.hoccerHistoryController.parentNavigationController = navigationController;
	self.hoccerHistoryController.hoccerViewController = self;
	self.hoccerHistoryController.historyData = historyData;
	
	desktopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lochblech_bg.png"]];
	tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bar.png"]];

	CGRect statusRect = statusViewController.view.frame;
	statusRect.origin.y = 0;

	[desktopView addSubview:statusViewController.view];
	statusViewController.view.frame = statusRect;
	
	[desktopView addSubview:infoViewController.view];
	infoViewController.view.frame = statusRect;
	infoViewController.largeBackground = [UIImage imageNamed:@"statusbar_large_hoccability.png"];
	[infoViewController setState:[LocationState state]];
	[infoViewController hideViewAnimated: NO];
	
	helpController = [[HelpController alloc] initWithController:navigationController];
	[helpController viewDidLoad];
	
	[self showHud];
}

- (void) dealloc {
	[hoccerHistoryController release];
	[navigationController release];
	[navigationItem release];
	[tabBar release];
	[auxiliaryView release];
	[delayedAction release];
	[helpController release];
	
	[super dealloc];
}

- (void)setContentPreview: (HoccerContent *)content {
	[super setContentPreview:content];
	
	self.tabBar.selectedItem = nil;
	[self setHoccabilityButton: [[self.hoccabilityInfo objectForKey:@"quality"] intValue]];
}

- (IBAction)selectContacts: (id)sender {
	[self hidePopOverAnimated: YES];
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (IBAction)selectImage: (id)sender {
	self.tabBar.selectedItem = NO;
	[self hidePopOverAnimated: NO];
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}

- (IBAction)selectVideo: (id)sender {
	[self hidePopOverAnimated: NO];
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	
	imagePicker.delegate = self;
	imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}

- (IBAction)selectText: (id)sender {
	[self hidePopOverAnimated: YES];
	
	HoccerContent* content = [[[HoccerText alloc] init] autorelease];
	[self setContentPreview: content];
}

- (IBAction)selectCamera: (id)sender {
	[self hidePopOverAnimated: NO];
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
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
	
	navigationItem.title = NSLocalizedString(@"Settings", nil);
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																			target:self action:@selector(cancelPopOver)];
	navigationItem.rightBarButtonItem = cancel;
	[cancel release];
	navigationItem.titleView = nil;
}

- (void)showHistoryView {
	[self showPopOver: self.hoccerHistoryController];
	
	navigationItem.title = NSLocalizedString(@"History", nil);
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																			target:self action:@selector(cancelPopOver)];
	navigationItem.rightBarButtonItem = cancel;
	[cancel release];
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
	
	statusViewController.hidden = YES;
	[popOverView viewDidAppear:YES];
}

- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	[self removePopOverFromSuperview];
}

- (void)removePopOverFromSuperview {
	statusViewController.hidden = NO;

	[auxiliaryView.view removeFromSuperview];	 
	self.auxiliaryView = nil;
	
	isPopUpDisplayed = NO;
	
	[self.delayedAction perform];
	self.delayedAction = nil;
	
	[self setHoccabilityButton: [[self.hoccabilityInfo objectForKey:@"quality"] intValue]];
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
	navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoccer_logo_bar.png"]] autorelease];
}

#pragma mark -
#pragma mark Linccer Delegate Methods
- (void) linccer:(HCLinccer *)aLinccer didUpdateEnvironment:(NSDictionary *)quality {
	[super linccer:aLinccer didUpdateEnvironment:quality];

	self.hoccabilityInfo = quality;
	[self setHoccabilityButton: [[self.hoccabilityInfo objectForKey:@"quality"] intValue]];
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

#pragma mark -
#pragma mark User Actions
- (IBAction)cancelPopOver {
	tabBar.selectedItem = nil;
	[self hidePopOverAnimated:YES];
}


#pragma mark -
#pragma mark Private Methods
- (void)setHoccabilityButton: (NSInteger)theHoccability {
	if (navigationItem.titleView == nil) {
		return;
	}
	
	if (theHoccability == 0) {
		navigationItem.rightBarButtonItem = nil;
		return;
	}
	
	UIImage *hoccabilityImage = nil; 
	switch (theHoccability) {
		case 1:
			hoccabilityImage = [UIImage imageNamed: @"statusbar_indicator_yellow.png"];
			break;
		case 2:
		case 3:
			hoccabilityImage = [UIImage imageNamed: @"statusbar_indicator_green.png"];
			break;
		default:
			hoccabilityImage = [UIImage imageNamed: @"statusbar_indicator_red.png"];
			break;
	}
	
	UIButton *hoccabilityButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[hoccabilityButton addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
	
	hoccabilityButton.frame = CGRectMake(0, 0, 36, 52);
	[hoccabilityButton setImage:hoccabilityImage forState:UIControlStateNormal];
								   
	UIBarButtonItem *hoccabilityBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:hoccabilityButton];
	navigationItem.rightBarButtonItem = hoccabilityBarButtonItem;
	[hoccabilityBarButtonItem release];
    
    // DEBUG
    UIBarButtonItem *debug = [[UIBarButtonItem alloc] initWithTitle:@"FAIL!" style:UIBarButtonItemStyleBordered target:self action:@selector(log:)];
    navigationItem.leftBarButtonItem = debug;
    [debug release];
    //

}

- (void)log:(id)sender {
    NSString *path = [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:@"log.txt"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:path];
    [file seekToEndOfFile];
    
    CLLocation *location = linccer.environmentController.environment.location;
    NSString *message = [NSString stringWithFormat:@"%@ <%f, %f  ~%f>\n", [NSDate date], location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy];
    [file writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}


- (void)pressedButton: (id)sender {	
	if (infoViewController.view.hidden == NO) {
		[infoViewController setLocationHint:nil];
	} else {
		[infoViewController setLocationHint: [HCEnvironmentManager messageForLocationInformation: hoccabilityInfo]];
	}
}

- (void) showNetworkError:(NSError *)error {
	[super showNetworkError:error];
	[self setHoccabilityButton:0];
}

- (void)ensureViewIsHoccable {
	[super ensureViewIsHoccable];
	[self setHoccabilityButton: [[self.hoccabilityInfo objectForKey:@"quality"] intValue]];
}


@end
