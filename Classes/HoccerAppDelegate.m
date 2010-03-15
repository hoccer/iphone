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
#import "HoccerUrl.h"

#import "FeedbackProvider.h"

#import "AboutViewController.h"
#import "HelpScrollView.h"
#import "TermOfUse.h"

#import "WifiScanner.h"
#import "HocLocation.h"

@interface HoccerAppDelegate ()

@property (retain) NSDate *lastLocationUpdate;

- (void)userNeedToAgreeToTermsOfUse;

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
	
	CFBooleanRef agreedToTermsOfUse = (CFBooleanRef)CFPreferencesCopyAppValue(CFSTR("termsOfUse"), CFSTR("com.artcom.Hoccer"));
	if (agreedToTermsOfUse == NULL) {
		[self userNeedToAgreeToTermsOfUse];
	}
	
	[WifiScanner sharedScanner];
	
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

- (void)didDissmissContentToThrow
{
	[contentToSend contentWillBeDismissed];
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
		
	if (request != nil) {
		return;
	}

	[FeedbackProvider  playCatchFeedback];

	HocLocation *hocLocation = [[[HocLocation alloc] 
								 initWithLocation:[self currentLocation] 
								 bssids:[WifiScanner sharedScanner].bssids] autorelease];
	
	request = [[HoccerDownloadRequest alloc] initWithLocation: hocLocation gesture: @"distribute" delegate: self];
	
	[hoccerViewController showConnectionActivity];
}


- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter
{
	if (!self.contentToSend)
		return;
	
	if (request != nil) {
		return;
	}
	
	
	[FeedbackProvider playThrowFeedback];
	[hoccerViewController startPreviewFlyOutAniamation];
	[hoccerViewController setUpdate: @"preparing"];
	
	HocLocation *hocLocation = [[[HocLocation alloc] 
								 initWithLocation:[self currentLocation] 
								 bssids:[WifiScanner sharedScanner].bssids] autorelease];
	request = [[HoccerUploadRequest alloc] initWithLocation:hocLocation gesture:@"distribute" content: contentToSend 
													   type: [contentToSend mimeType] filename: [contentToSend filename] delegate:self];
	
	[hoccerViewController showConnectionActivity];
}


#pragma mark -
#pragma mark Download Communication Delegate Methods


- (void)requestIsReadyToStartDownload: (BaseHoccerRequest *)aRequest
{
	if ([HoccerContentFactory isSupportedType: [aRequest.response MIMEType]])
		return;
	
	[aRequest cancel];
	
	NSURL *url = [aRequest.request URL];
	self.hoccerContent = [[HoccerUrl alloc] initWithData: [[url absoluteString] dataUsingEncoding: NSUTF8StringEncoding]];
	
	receivedContentView = [[ReceivedContentView alloc] initWithNibName:@"ReceivedContentView" bundle:nil];
	
	receivedContentView.delegate = self;
	[receivedContentView setHoccerContent: self.hoccerContent];
	
	[viewController presentModalViewController: receivedContentView animated:YES];
	
	[request release];
	request = nil;
	
	[hoccerViewController hideConnectionActivity];
}

- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest
{
	self.hoccerContent = [HoccerContentFactory createContentFromResponse: aRequest.response 
														    withData: aRequest.result];
	
	receivedContentView = [[ReceivedContentView alloc] initWithNibName:@"ReceivedContentView" bundle:nil];
	
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
	if ([hoccerContent needsWaiting])  {
		[receivedContentView setWaiting];
		[hoccerContent whenReadyCallTarget: self selector: @selector(hideReceivedContentView)];

		[hoccerContent save];
	} else {
		[self hideReceivedContentView];

		[hoccerContent save];
	}
}


- (void)userDidDismissContent
{
	[self hideReceivedContentView];
}

-  (void)hideReceivedContentView 
{
	[viewController dismissModalViewControllerAnimated:YES];
	[receivedContentView release];
}


- (void)userDidChoseAboutView
{
	AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	aboutViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	aboutViewController.delegate = self;
	
	[viewController presentModalViewController:aboutViewController animated:YES];
	
	[aboutViewController release];	
}


- (void)userDidCloseAboutView
{
	[viewController dismissModalViewControllerAnimated:YES];
}


- (void)userDidChoseHelpView
{
	HelpScrollView  *help = [[HelpScrollView alloc] init];
	help.delegate = self;
	help.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[viewController presentModalViewController:help animated:YES];

	gesturesInterpreter.delegate = help;
	[help release];
}

- (void)userDidCloseHelpView
{
	[viewController dismissModalViewControllerAnimated:YES];
	gesturesInterpreter.delegate = self;
}

- (void)userNeedToAgreeToTermsOfUse
{
	TermOfUse *terms = [[TermOfUse alloc] init];
	
	terms.delegate = self;
	[viewController presentModalViewController:terms animated:NO];
	
	[terms release];
}

- (void)userDidAgreeToTermsOfUse
{
	[viewController dismissModalViewControllerAnimated:YES];
	
	CFBooleanRef agreed = kCFBooleanTrue;
	CFPreferencesSetAppValue(CFSTR("termsOfUse"), agreed, CFSTR("com.artcom.Hoccer"));

	CFPreferencesAppSynchronize(CFSTR("com.artcom.Hoccer"));
}

- (void)userWantsToSelectImage
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	
	imagePicker.delegate = self;
	[viewController presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}

- (void)userWantsToSelectContact
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	[viewController presentModalViewController:picker animated:YES];
	[picker release];
}

#pragma mark -
#pragma mark Saving Delegate Methods

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	[viewController dismissModalViewControllerAnimated:YES];
}

@end
