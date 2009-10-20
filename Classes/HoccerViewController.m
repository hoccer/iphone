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
	[saveButton release];
	[toolbar release];
    [statusLabel release];
	[locationLabel release];
	
	[previewBox release];
	[activitySpinner release];
	
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
	statusLabel.text = update;
}	

- (void)showConnectionActivity
{
	[activitySpinner startAnimating];
}

- (void)hideConnectionActivity
{
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
				  destructiveButtonTitle:nil otherButtonTitles: @"Contact", @"Image", nil];
	
	[sheet showFromToolbar: toolbar];
	[sheet autorelease];
}


- (void)setContentPreview: (id <HoccerContent>)content
{
	UIView *contentView = content.preview;
	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
	contentView.frame = CGRectMake(xOrigin, 40, contentView.frame.size.width, contentView.frame.size.height);
	
	[self.view addSubview: contentView];
	[self.view setNeedsDisplay];
}

 - (void)startPreviewFlyOutAniamation
{
	
}


#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	switch (buttonIndex) {
		case 0:
			NSLog(@"image");

			ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
			picker.peoplePickerDelegate = self.delegate;
			
			[self presentModalViewController:picker animated:YES];
			[picker release];
			break;
		case 1:
			NSLog(@"image");

			UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
			
			imagePicker.delegate = self.delegate;
			[self presentModalViewController:imagePicker animated:YES];
			[imagePicker release];

			
			break;
		default:
			break;
	}
}





@end
