//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#import "NSObject+DelegateHelper.h"
#import "NSString+StringWithData.h"

#import "HoccerViewController.h"
#import "HoccerAppDelegate.h"

#import "HoccerVcard.h"
#import "HoccerText.h"
#import "Preview.h"
#import "ContentContainerView.h"

#import "DesktopView.h"
#import "ReceivedContentViewController.h"
#import "SelectContentViewController.h"

#import "HelpScrollView.h"

#import "HoccerImage.h"
#import "HoccerText.h"
#import "HoccerVcard.h"
#import "HoccerContent.h"

#import "DesktopDataSource.h"
#import "FeedbackProvider.h"
#import "GesturesInterpreter.h"
#import "LocationController.h"

#import "HocItemData.h"
#import "StatusViewController.h"



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

@interface HoccerViewController ()

@property (retain) ActionElement* delayedAction;

- (void)showPopOver: (UIViewController *)popOverView;
- (void)hidePopOverAnimated: (BOOL) animate;
- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)showSelectContentView;
- (void)showHelpView;
- (void)removePopOverFromSuperview;

@end

@implementation HoccerViewController

@synthesize delegate; 
@synthesize auxiliaryView;
@synthesize allowSweepGesture;
@synthesize helpViewController;
@synthesize delayedAction;
@synthesize locationController;
@synthesize gestureInterpreter;
@synthesize statusViewController;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	self.helpViewController = nil;
}

- (void)viewDidLoad {
	desktopView.delegate = self;

	desktopData = [[DesktopDataSource alloc] init];
	desktopData.viewController = self;
	
    isPopUpDisplayed = FALSE;
	
	self.allowSweepGesture = YES;	
	desktopView.shouldSnapToCenterOnTouchUp = YES;
	
	[self.view insertSubview:statusViewController.view atIndex:1];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[delayedAction release];

	[desktopView release];	
	[helpViewController release];
	
	[auxiliaryView release];
	[super dealloc];
}

#pragma mark -
#pragma mark User Action

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
	
	gestureInterpreter.delegate = self;
	self.allowSweepGesture = NO;
}

- (IBAction)toggleHelp: (id)sender {
	if (!isPopUpDisplayed) {			
		[self showHelpView];
	} else if (auxiliaryView != self.helpViewController) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showHelpView)];
		[self hidePopOverAnimated: YES];
	} else {
		[self hidePopOverAnimated: YES];
		gestureInterpreter.delegate = self;	
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
		gestureInterpreter.delegate = (NSObject *) self.helpViewController;
	}
}


#pragma mark -
#pragma mark View Manipulation

- (void)showError: (NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil 
											  cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	
	[alertView show];
	[alertView release];
}


- (void)resetPreview {
	[desktopView resetView];
}

- (void)startPreviewFlyOutAniamation {
	[desktopView startFlyOutUpwardsAnimation];
}

- (void)showSelectContentView {
	SelectContentViewController *selectContentViewController = [[SelectContentViewController alloc] init];
	selectContentViewController.delegate = self;
	
	[self showPopOver: selectContentViewController];
	[selectContentViewController release];
	
	gestureInterpreter.delegate = nil;
}

- (void)showHelpView {
	self.helpViewController.delegate = self;
	
	[self showPopOver:self.helpViewController];
	gestureInterpreter.delegate = (NSObject *) self.helpViewController;
}

- (void)showPopOver: (UIViewController *)popOverView  {
	self.auxiliaryView = popOverView;
	
	CGRect selectContentFrame = popOverView.view.frame;
	selectContentFrame.size = desktopView.frame.size;
	selectContentFrame.origin= CGPointMake(0, self.view.frame.size.height);
	popOverView.view.frame = selectContentFrame;	
	
	[desktopView addSubview:popOverView.view];
	
	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	selectContentFrame.origin = CGPointMake(0,0);
	popOverView.view.frame = selectContentFrame;
	[UIView commitAnimations];
	
	 isPopUpDisplayed = TRUE;
}

- (void)presentReceivedContent:(HoccerContent*) hoccerContent
{
	receivedContentViewController = [[ReceivedContentViewController alloc] initWithNibName:@"ReceivedContentView" bundle:nil];
	
	receivedContentViewController.delegate = self;
	[receivedContentViewController setHoccerContent: hoccerContent];
		
	[self presentModalViewController: receivedContentViewController animated:YES];	
    [self resetPreview];
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


- (HelpScrollView *)helpViewController {
	if (helpViewController == nil) {
		helpViewController = [[HelpScrollView alloc] init];
	}
	
	return helpViewController;
}


- (void)receivedViewContentControllerDidFinish:(ReceivedContentViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)setContentPreview: (HoccerContent *)content {
	
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	HoccerContent* content = [[[HoccerImage alloc] initWithUIImage:
								   [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease];
	
	gestureInterpreter.delegate = self;
	self.allowSweepGesture = NO;
	
	[self setContentPreview: content];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ABPeoplePickerNavigationController delegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	ABRecordID contactId = ABRecordGetRecordID(person);
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef fullPersonInfo = ABAddressBookGetPersonWithRecordID(addressBook, contactId);
	
	HoccerContent* content = [[[HoccerVcard alloc] initWitPerson:fullPersonInfo] autorelease];
	
	gestureInterpreter.delegate = self;
	self.allowSweepGesture = NO;
	[self setContentPreview: content];
	
	[self dismissModalViewControllerAnimated:YES];
	CFRelease(addressBook);
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property 
							  identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker 
{
	[self dismissModalViewControllerAnimated:YES];
	gestureInterpreter.delegate = self;
}

#pragma mark -
#pragma mark GesturesInterpreter Delegate Methods

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter {
	if ([desktopData controllerHasActiveRequest]) {
		return;
	}
	self.allowSweepGesture = NO;
	
	[FeedbackProvider playCatchFeedback];
	// request = [[HoccerDownloadRequest alloc] initWithLocation: locationController.location gesture: @"distribute" delegate: self];
	
	// [statusViewController showActivityInfo];
}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter {
	if ([desktopData controllerHasActiveRequest]) {
		return;
	}
	
	[FeedbackProvider playThrowFeedback];
	[self startPreviewFlyOutAniamation];
	
	[[desktopData hocItemDataAtIndex:0] uploadWithLocation:locationController.location gesture:@"distribute"];
	
	// [statusViewController showActivityInfo];
}


#pragma mark -
#pragma mark DesktopViewDelegate

- (void)desktopView: (DesktopView *)desktopView didSweepInView: (UIView *)view {
	NSLog(@"sweeping out");
	if ([desktopData controllerHasActiveRequest]) {
		return;
	}
	
	self.allowSweepGesture = NO;
	
	HocItemData *item = [desktopData hocItemDataForView: view];
	[item downloadWithLocation:locationController.location gesture:@"pass"];
	
	// [statusViewController showActivityInfo];
}

- (void)desktopView: (DesktopView *)desktopView didSweepOutView: (UIView *)view {
	if ([desktopData controllerHasActiveRequest]) {
		return;
	}
	
	HocItemData *item = [desktopData hocItemDataForView: view];
	[item uploadWithLocation:locationController.location gesture:@"pass"];
	
	statusViewController.hocItemData = item;
	[statusViewController showActivityInfo];
}

- (UIView *)desktopView: (DesktopView *)aDesktopView needsEmptyViewAtPoint: (CGPoint)point {
	if ([desktopData controllerHasActiveRequest]) {
		return nil;
	}
	
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.delegate = self;
	
	[desktopData addHocItem:item];
	[desktopView reloadData];
	
	return item.contentView;
}

#pragma mark -
#pragma mark HocItemDataDelegate

- (void)hocItemWasSend: (HocItemData *)item {
	NSLog(@"hocItemWasSend:");
	statusViewController.hocItemData = nil;
	
	[desktopData removeHocItem:item];
	[desktopView reloadData];
}

- (void)hocItemWasReceived: (HocItemData *)item {
	NSLog(@"hocItemWasReceived:");
	statusViewController.hocItemData = nil;

	[desktopView reloadData];
}

- (void)hocItemWasCanceled: (HocItemData *)item {
	NSLog(@"hocItemWasCanceled:");
	statusViewController.hocItemData = nil;

	item.viewOrigin = CGPointMake(200, 300);
	[desktopView reloadData];
}



@end
