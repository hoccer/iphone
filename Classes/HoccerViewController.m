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

#import "PreviewViewController.h"
#import "DesktopViewController.h"
#import "ReceivedContentViewController.h"
#import "SelectContentViewController.h"

#import "HelpScrollView.h"

#import "HoccerImage.h"
#import "HoccerText.h"
#import "HoccerVcard.h"
#import "HoccerContent.h"



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
@synthesize previewViewController;


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	self.helpViewController = nil;
}

- (void)viewDidLoad {
	previewViewController = [[PreviewViewController alloc] init];
	previewViewController.delegate = self;
	
	desktopViewController = [[DesktopViewController alloc] init];
	desktopViewController.view = backgroundView;
	desktopViewController.feedback = sweepInView;
	desktopViewController.delegate = self.delegate;
	
	sweepInView.hidden = YES;
    isPopUpDisplayed = FALSE;
	[backgroundView addSubview: sweepInView];
	
	self.allowSweepGesture = YES;	
	previewViewController.shouldSnapBackOnTouchUp = YES;
	desktopViewController.shouldSnapToCenterOnTouchUp = YES;
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[delayedAction release];
	[sweepInView release];

	[previewViewController release];		
	[desktopViewController release];	
	[helpViewController release];
	
	[backgroundView release];
	[auxiliaryView release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark User Action

- (IBAction)didDissmissContentToThrow: (id)sender {
	[self setContentPreview: nil];

	[self.delegate checkAndPerformSelector: @selector(hoccerViewControllerDidDismissSelectedContent:) withObject:self];
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
	
	id <HoccerContent> content = [[[HoccerText alloc] init] autorelease];
	[self setContentPreview: content];
	
	[self.delegate checkAndPerformSelector:@selector(hoccerViewController:didSelectContent:) withObject:self withObject: content];
}

- (IBAction)toggleHelp: (id)sender {
	if (!isPopUpDisplayed) {			
		[self showHelpView];
	} else if (auxiliaryView != self.helpViewController) {
		self.delayedAction = [ActionElement actionElementWithTarget: self selector:@selector(showHelpView)];
		[self hidePopOverAnimated: YES];
	} else {
		[self hidePopOverAnimated: YES];
		[self.delegate checkAndPerformSelector:@selector(hoccerViewControllerDidCancelHelp:) withObject:self];
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
		[self.delegate checkAndPerformSelector:@selector(hoccerViewControllerDidCancelContentSelector:) withObject:self];
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

- (void)setContentPreview: (id <HoccerContent>)content {
	[previewViewController.view removeFromSuperview];
	Preview *contentView = [content thumbnailView];
	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
	
	[backgroundView insertSubview: contentView atIndex: 1];
	[self.view setNeedsDisplay];
	
	previewViewController.view = contentView;	
	previewViewController.origin = CGPointMake(xOrigin, 25);
}

- (void)resetPreview {
	[previewViewController resetViewAnimated:NO];
	[desktopViewController resetView];
}

- (void)startPreviewFlyOutAniamation {
	[previewViewController startFlyOutUpwardsAnimation];
}

- (void)showSelectContentView {
	SelectContentViewController *selectContentViewController = [[SelectContentViewController alloc] init];
	selectContentViewController.delegate = self;
	
	[self showPopOver: selectContentViewController];
	[selectContentViewController release];
	
	[self.delegate checkAndPerformSelector:@selector(hoccerViewControllerDidShowContentSelector:) withObject:self];
}

- (void)showHelpView {
	self.helpViewController.delegate = self;
	
	[self showPopOver:self.helpViewController];
	[self.delegate checkAndPerformSelector:@selector(hoccerViewControllerDidShowHelp:) withObject:self];
}

- (void)showPopOver: (UIViewController *)popOverView  {
	self.auxiliaryView = popOverView;
	
	CGRect selectContentFrame = popOverView.view.frame;
	selectContentFrame.size = desktopViewController.view.frame.size;
	selectContentFrame.origin= CGPointMake(0, self.view.frame.size.height);
	popOverView.view.frame = selectContentFrame;	
	
	[desktopViewController.view addSubview:popOverView.view];
	
	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	selectContentFrame.origin = CGPointMake(0,0);
	popOverView.view.frame = selectContentFrame;
	[UIView commitAnimations];
	
	 isPopUpDisplayed = TRUE;
}

- (void)presentReceivedContent:(id <HoccerContent>) hoccerContent{
	
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

- (void)setAllowSweepGesture: (BOOL)allow {
	desktopViewController.blocked = !allow;
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


#pragma mark -
#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	id <HoccerContent> content = [[[HoccerImage alloc] initWithUIImage:
								   [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease];
	
	[self.delegate checkAndPerformSelector:@selector(hoccerViewController:didSelectContent:) withObject:self withObject: content];
	
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
	
	id <HoccerContent> content = [[[HoccerVcard alloc] initWitPerson:fullPersonInfo] autorelease];
	
	[self.delegate checkAndPerformSelector:@selector(hoccerViewController:didSelectContent:) withObject:self withObject: content];
	[self setContentPreview: content];
	
	[self dismissModalViewControllerAnimated:YES];
	CFRelease(fullPersonInfo);
	
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
	[self.delegate checkAndPerformSelector:@selector(hoccerViewControllerDidCancelContentSelector:) withObject:self];
}

#pragma mark -
#pragma mark Touch Events
- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	[previewViewController dismissKeyboard];
}

- (void) sweepInterpreterDidDetectSweepOut {
	[self.delegate checkAndPerformSelector:@selector(sweepInterpreterDidDetectSweepOut)];
}

@end
