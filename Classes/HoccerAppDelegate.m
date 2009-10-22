//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "HoccerAppDelegate.h"
#import "HoccerViewController.h"
#import "ReceivedContentView.h"

#import "BaseHoccerRequest.h"

#import "HoccerDownloadRequest.h"
#import "HoccerUploadRequest.h"
#import "GesturesInterpreter.h"

#import "HoccerContentFactory.h"
#import "HoccerImage.h"
#import "HoccerText.h"
#import "HoccerVcard.h"

#import "FeedbackProvider.h"

#import "SelectViewController.h"

@interface HoccerAppDelegate ()

@property (retain) NSDate *lastLocationUpdate;

@end



@implementation HoccerAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize contentToSend;
@synthesize hoccerContent;

@synthesize lastLocationUpdate;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	application.applicationSupportsShakeToEdit = NO;
	
	gesturesInterpreter = [[GesturesInterpreter alloc] init];
	gesturesInterpreter.delegate = self;
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];

	[request release];

	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[locationManager stopUpdatingLocation];
	[locationManager release];
	locationManager = nil;
	
	[hoccerContent release];
	[contentToSend release];
	[request release];
	
    [viewController release];
	[navigationController release];
    [window release];
	
	[lastLocationUpdate release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)aViewController
{
	NSLog(@"selected class: %@", aViewController);
}

- (void)didDissmissContentToThrow
{
	self.contentToSend = nil;
	[hoccerViewController setContentPreview: nil];
}



#pragma mark -
#pragma mark UIImagePickerController Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.contentToSend = [[[HoccerImage alloc] initWithUIImage:
						   [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease] ;
	
	[hoccerViewController setContentPreview: self.contentToSend];
	
	[viewController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark ABPeoplePickerNavigationController delegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	ABRecordID id = ABRecordGetRecordID(person);
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef fullPersonInfo = ABAddressBookGetPersonWithRecordID(addressBook, id);
	
	
	self.contentToSend = [[[HoccerVcard alloc] initWitPerson:fullPersonInfo] autorelease];
	[hoccerViewController setContentPreview: self.contentToSend];
	
	[viewController dismissModalViewControllerAnimated:YES];
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
	[viewController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Text Delegate Methods 

- (void)userDidPickText
{
	self.contentToSend = [[[HoccerText alloc] init] autorelease];
	
	[hoccerViewController  setContentPreview: self.contentToSend];
}

#pragma mark -
#pragma mark GesturesInterpreter Delegate Methods

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter
{
	if (self.contentToSend)
		return;
	
	NSLog(@"im catching, wooo");
	
	if (request != nil) {
		return;
	}

	[FeedbackProvider  playCatchFeedback];

	CLLocation *location = [self currentLocation];
	request = [[HoccerDownloadRequest alloc] initWithLocation: location gesture: @"distribute" delegate: self];
	
	[hoccerViewController showConnectionActivity];
}


- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter
{
	if (!self.contentToSend)
		return;
	
	NSLog(@"im throwing, wooo");
	
	if (request != nil) {
		return;
	}
	
	
	[FeedbackProvider playThrowFeedback];
	[hoccerViewController startPreviewFlyOutAniamation];
	[hoccerViewController setUpdate: @"preparing"];
	
	CLLocation *location = [self currentLocation];
	request = [[HoccerUploadRequest alloc] initWithLocation:location gesture:@"distribute" content: contentToSend 
													   type: [contentToSend mimeType] filename: [contentToSend filename] delegate:self];
	
	[hoccerViewController showConnectionActivity];
}


#pragma mark -
#pragma mark Download Communication Delegate Methods

- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest
{
	self.hoccerContent = [HoccerContentFactory createContentFromResponse: aRequest.response 
														    withData: aRequest.result];
	
	receivedContentView = [[[ReceivedContentView alloc] initWithNibName:@"ReceivedContentView" bundle:nil] autorelease];
	
	receivedContentView.delegate = self;
	[receivedContentView setHoccerContent: self.hoccerContent];
	
	[viewController presentModalViewController: receivedContentView animated:YES];

	[request release];
	request = nil;
	
	[hoccerViewController hideConnectionActivity];
}


#pragma mark -
#pragma mark Upload Communication 

- (void)requestDidFinishUpload: (BaseHoccerRequest *)aRequest
{
	[request release];
	request = nil;
	
	self.contentToSend = nil;
	[hoccerViewController setContentPreview: nil];

	[hoccerViewController hideConnectionActivity];
}


#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	[hoccerViewController showError: [error localizedDescription]];
	[hoccerViewController resetPreview];
	
	[request release];
	request = nil;
	
	[hoccerViewController hideConnectionActivity];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update 
{
	[hoccerViewController setUpdate: update];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress
{
	[hoccerViewController setProgressUpdate:[progress floatValue]];
}


- (CLLocation *) currentLocation
{
	return locationManager.location;
}

#pragma mark -
#pragma mark Reverse Geocoding Methods


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation {
	
	if ([[NSDate date] timeIntervalSinceDate: lastLocationUpdate] < 10)
		return;
	
	MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate: newLocation.coordinate];
	geocoder.delegate = self;
	
	[geocoder start];
	
	self.lastLocationUpdate = [NSDate date];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	[geocoder release];
	CLLocation *location = [self currentLocation];
	
	[hoccerViewController setLocation:placemark withAccuracy: location.horizontalAccuracy];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError: (NSError *)error
{
}

#pragma mark -
#pragma mark Interaction Delegate Methods

- (void)userDidCancelRequest
{
	[hoccerViewController resetPreview];
	[hoccerViewController hideConnectionActivity];
	
	[request cancel];
	[request release];
	
	request = nil;
}


- (void)userDidSaveContent
{
	[hoccerContent save];
	[viewController dismissModalViewControllerAnimated:YES];
}


- (void)userDidDismissContent
{
	[viewController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Saving Delegate Methods

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	NSLog(@"did save: error: %@", error);

	[viewController dismissModalViewControllerAnimated:YES];
}

@end
