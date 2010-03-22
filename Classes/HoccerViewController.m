//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ABPersonVCardCreator.h"
#import "NSObject+DelegateHelper.h"
#import "NSString+StringWithData.h"

#import "HoccerViewController.h"
#import "HoccerAppDelegate.h"

#import "HoccerVcard.h"
#import "HoccerText.h"
#import "Preview.h"

#import "HiddenViewScrollViewDelegate.h"
#import "PreviewViewController.h"
#import "BackgroundViewController.h"
#import "SelectContentViewController.h"

#import "HelpScrollView.h"

#import "HoccerImage.h"
#import "HoccerText.h"
#import "HoccerVcard.h"

@interface HoccerViewController ()

- (void)showPopOver: (UIViewController *)popOverView;
- (void)hidePopOverAnimated: (BOOL) animate;
- (void)removePopOverFromSuperview;

- (void)showSelectContentView;
- (void)showHelpView;

@end


@implementation HoccerViewController

@synthesize delegate; 
@synthesize popOver;
@synthesize allowSweepGesture;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	previewViewController = [[PreviewViewController alloc] init];
	previewViewController.delegate = self;
	
	backgroundViewController = [[BackgroundViewController alloc] init];
	backgroundViewController.view = backgroundView;
	backgroundViewController.feedback = sweepInView;
	backgroundViewController.delegate = self.delegate;
	
	sweepInView.hidden = YES;
    isPopUpDisplayed = FALSE;
	[backgroundView addSubview: sweepInView];
	
	self.allowSweepGesture = YES;
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[sweepInView release];

	[previewViewController release];		
	[backgroundViewController release];		
	
	[backgroundView release];
	
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
	} else {
		[self hidePopOverAnimated: YES];
	}
}

- (IBAction)toggleSelectContent: (id)sender {
	if (!isPopUpDisplayed) {			
		[self showSelectContentView];
		[self.delegate checkAndPerformSelector:@selector(hoccerViewControllerDidShowContentSelector:) withObject:self];
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


- (void)showReceiveMode {
}

- (void)showSendMode {
}


- (void)setContentPreview: (id <HoccerContent>)content {
	if (content == nil) {
		[self showReceiveMode];
	} else {
		[self showSendMode];
	}
	
	[previewViewController.view removeFromSuperview];
	Preview *contentView = [content preview];
	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
	
	[backgroundView insertSubview: contentView atIndex: 1];
	[self.view setNeedsDisplay];
	
	previewViewController.view = contentView;	
	previewViewController.origin = CGPointMake(xOrigin, 25);
}

- (void)resetPreview {
	[previewViewController resetViewAnimated:NO];
	[backgroundViewController resetView];
}

- (void)startPreviewFlyOutAniamation {
	[previewViewController startFlyOutUpwardsAnimation];
}

- (void)showSelectContentView {
	SelectContentViewController *selectContentViewController = [[SelectContentViewController alloc] init];
	selectContentViewController.delegate = self;
	
	[self showPopOver: selectContentViewController];
	[selectContentViewController release];
}

- (void)showHelpView {
	HelpScrollView *helpView = [[HelpScrollView alloc] init];
	helpView.delegate = self;
	
	[self showPopOver:helpView];
	[helpView release];
}

- (void)showPopOver: (UIViewController *)popOverView  {
	self.popOver = popOverView;
	
	CGRect selectContentFrame = popOverView.view.frame;
	selectContentFrame.size = backgroundViewController.view.frame.size;
	selectContentFrame.origin= CGPointMake(0, self.view.frame.size.height);
	popOverView.view.frame = selectContentFrame;	
	
	[backgroundViewController.view addSubview:popOverView.view];
	
	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	selectContentFrame.origin = CGPointMake(0,0);
	popOverView.view.frame = selectContentFrame;
	[UIView commitAnimations];
	
	 isPopUpDisplayed = TRUE;
}

- (void)hidePopOverAnimated: (BOOL) animate {
	if (self.popOver != nil) {		
		CGRect selectContentFrame = self.popOver.view.frame;
		selectContentFrame.origin = CGPointMake(0, self.view.frame.size.height);
		
		if (animate) {
			[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
			[UIView setAnimationDidStopSelector:@selector(removePopOverFromSuperview)];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.2];
			
			self.popOver.view.frame = selectContentFrame;
			
			[UIView commitAnimations];
		} else {
			self.popOver.view.frame = selectContentFrame;
			[self removePopOverFromSuperview];
		}

	}
}

- (void)removePopOverFromSuperview {	
	[popOver.view removeFromSuperview];	 
	self.popOver = nil;

	isPopUpDisplayed = NO;
}

- (void)setAllowSweepGesture: (BOOL)allow {
	backgroundViewController.blocked = !allow;
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






@end
