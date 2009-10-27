//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>


#import "ABPersonVCardCreator.h"
#import "NSObject+DelegateHelper.h"
#import  "NSString+StringWithData.h"

#import "HoccerViewController.h"
#import "HoccerDownloadRequest.h"
#import "HoccerUploadRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerContentFactory.h"
#import "GesturesInterpreter.h"
#import "HoccerAppDelegate.h"

#import "HoccerVcard.h"
#import "HoccerText.h"
#import "PreviewView.h"


@implementation HoccerViewController

@synthesize delegate; 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad {
	
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[cancelButton release];
	[toolbar release];
    [statusLabel release];
	[locationLabel release];
	[infoView release];
	
	[activitySpinner release];
	[progressView release];
	[modeLabel release];
	[successView release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark User Interaction
- (IBAction)onCancel: (id)sender 
{
	[self.delegate checkAndPerformSelector:@selector(userDidCancelRequest)];
}

- (IBAction)didDissmissContentToThrow: (id)sender
{
	[self.delegate checkAndPerformSelector: @selector(didDissmissContentToThrow)];
}

- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy
{
	if (placemark.thoroughfare != nil)
		locationLabel.text = [NSString stringWithFormat:@"%@ (~ %4.2fm)", placemark.thoroughfare, accuracy];
}	
	
- (void)setUpdate: (NSString *)update
{
	progressView.hidden = YES;

	activitySpinner.hidden = NO;
	statusLabel.hidden = NO;
	statusLabel.text = update;
}

- (void)setProgressUpdate: (CGFloat) percentage
{
	statusLabel.hidden = YES;
	activitySpinner.hidden = YES;
	
	progressView.hidden = NO;
	progressView.progress = percentage;
}


- (void)showReceiveMode
{
	modeLabel.title = @"Receive";
	descriptionImage.hidden = NO;
}

- (void)showSendMode
{
	modeLabel.title = @"Share";
	descriptionImage.hidden = YES;
	
}

- (void)showSuccessMode
{
	successView.hidden = NO;
	[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideSuccessMode) userInfo:nil repeats:NO];
}

- (void)hideSuccessMode 
{
	successView.hidden = YES;
}


- (void)showConnectionActivity
{
	infoView.hidden = NO;
	
	// cancelButton.hidden = NO;
	[activitySpinner startAnimating];
}

- (void)hideConnectionActivity
{
	infoView.hidden = YES;
	// cancelButton.hidden = YES;

	
	[activitySpinner stopAnimating];
}

- (void)showError: (NSString *)message
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil 
											  cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	
	[alertView show];
	[alertView release];
}

- (IBAction)showActions: (id)sender
{
	UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
				  destructiveButtonTitle:nil otherButtonTitles: @"Contact", @"Image", @"Text", nil];
	
	[sheet showFromToolbar: toolbar];
	[sheet autorelease];
}


- (void)setContentPreview: (id <HoccerContent>)content
{
	if (content == nil) {
		[self showReceiveMode];
	} else {
		[self showSendMode];
	}
	
	[currentPreview removeFromSuperview];
	
	PreviewView *contentView = [content previewWithFrame: CGRectMake(0, 0, 175, 175)];
	
	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
	originalFrame = CGRectMake(xOrigin, 60, contentView.frame.size.width, contentView.frame.size.height);
		
	contentView.delegate = self.delegate;
	
	[self.view insertSubview: contentView atIndex: 1];
	[self.view setNeedsDisplay];
	
	currentPreview = contentView;
	[self resetPreview];
}

- (void)resetPreview
{
	
	// currentPreview.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, 0, 0)
	
	// [UIView beginAnimations:@"showPreviewAnimation" context:NULL];
	// [UIView setAnimationDuration: 1];
	currentPreview.frame = originalFrame;
	// [UIView commitAnimations];
}

#pragma mark -
#pragma mark animations
 - (void)startPreviewFlyOutAniamation
{
	[UIView beginAnimations:@"myFlyOutAnimation" context:NULL];
	currentPreview.frame = CGRectMake(currentPreview.frame.origin.x, -200, 20, 20);
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	switch (buttonIndex) {
		case 0:
			;
			ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
			picker.peoplePickerDelegate = self.delegate;
			
			[self presentModalViewController:picker animated:YES];
			[picker release];
			break;
		case 1:
			;
			UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
			
			imagePicker.delegate = self.delegate;
			[self presentModalViewController:imagePicker animated:YES];
			[imagePicker release];

			
			break;
		case 2:
			[self.delegate checkAndPerformSelector: @selector(userDidPickText)];
			
			break;
		default:
			break;
	}
}


- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	[currentPreview dismissKeyboard];
}

- (IBAction)showAbout: (id)sender 
{
	[self.delegate checkAndPerformSelector: @selector(userDidChoseAboutView)];
}




@end
