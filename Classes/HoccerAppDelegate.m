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

#import "HocLocation.h"
#import "LocationController.h"

#import "StatusViewController.h"

@interface HoccerAppDelegate ()

- (void)userNeedToAgreeToTermsOfUse;

@end


@implementation HoccerAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize contentToSend;
@synthesize hoccerContent;

@synthesize locationController;
@synthesize statusViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	application.applicationSupportsShakeToEdit = NO;
	application.idleTimerDisabled = YES;
	
	[request release];

	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
	
	[viewController.view insertSubview:statusViewController.view atIndex:4];

	
	CFBooleanRef agreedToTermsOfUse = (CFBooleanRef)CFPreferencesCopyAppValue(CFSTR("termsOfUse"), CFSTR("com.artcom.Hoccer"));
	if (agreedToTermsOfUse == NULL) {
		[self userNeedToAgreeToTermsOfUse];
	}
}

- (void)dealloc {	
	[hoccerContent release];
	[contentToSend release];
	[request release];
	
    [viewController release];
	[window release];
	
	[super dealloc];
}

- (void)didDissmissContentToThrow
{
	[contentToSend contentWillBeDismissed];
	self.contentToSend = nil;
	[viewController setContentPreview: nil];
}



#pragma mark -
#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.contentToSend = [[[HoccerImage alloc] initWithUIImage:
						   [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease] ;
	
	[viewController setContentPreview: self.contentToSend];
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
	[viewController setContentPreview: self.contentToSend];
	
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
	
	[viewController  setContentPreview: self.contentToSend];
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
#pragma mark GesturesInterpreter Delegate Methods

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter {
	if (self.contentToSend || request != nil) {
		return;
	}

	[FeedbackProvider  playCatchFeedback];
	request = [[HoccerDownloadRequest alloc] initWithLocation: locationController.location gesture: @"distribute" delegate: self];
	
	[statusViewController showActivityInfo];
}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter {
	if (!self.contentToSend || request != nil) {
		return;
	}
	
	[FeedbackProvider playThrowFeedback];
	[viewController startPreviewFlyOutAniamation];
	[statusViewController setUpdate: @"preparing"];

	request = [[HoccerUploadRequest alloc] initWithLocation:locationController.location gesture:@"distribute" content: contentToSend 
													   type: [contentToSend mimeType] filename: [contentToSend filename] delegate:self];
	
	[statusViewController showActivityInfo];
}

- (void)sweepInterpreterDidDetectSweepIn {	
	if (self.contentToSend || request != nil) {
		return;
	}
	
	request = [[HoccerDownloadRequest alloc] initWithLocation: locationController.location gesture: @"pass" delegate: self];
	[statusViewController showActivityInfo];
}

- (void)sweepInterpreterDidDetectSweepOut {
	if (!self.contentToSend || request != nil) {
		return;
	}
	
	[statusViewController setUpdate: @"preparing"];
	request = [[HoccerUploadRequest alloc] initWithLocation:locationController.location gesture:@"pass" content: contentToSend 
													   type: [contentToSend mimeType] filename: [contentToSend filename] delegate:self];
	
	[statusViewController showActivityInfo];
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
	
	[statusViewController hideActivityInfo];
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
	
	[statusViewController hideActivityInfo];
}


#pragma mark -
#pragma mark Upload Communication 

- (void)requestDidFinishUpload: (BaseHoccerRequest *)aRequest
{
	[request release];
	request = nil;
	
	self.contentToSend = nil;
	[viewController setContentPreview: nil];

	[statusViewController hideActivityInfo];
}

#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	[viewController showError: [error localizedDescription]];
	[viewController resetPreview];
	
	[request release];
	request = nil;
	
	[statusViewController hideActivityInfo];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update 
{
	[statusViewController setUpdate: update];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress
{
	[statusViewController setProgressUpdate:[progress floatValue]];
}

#pragma mark -
#pragma mark Interaction Delegate Methods

- (void)userDidCancelRequest
{
	[viewController resetPreview];
	[statusViewController hideActivityInfo];
	
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

	// gesturesInterpreter.delegate = help;
	[help release];
}

- (void)userDidCloseHelpView
{
	[viewController dismissModalViewControllerAnimated:YES];
	// gesturesInterpreter.delegate = self;
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



#pragma mark -
#pragma mark Saving Delegate Methods

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	[viewController dismissModalViewControllerAnimated:YES];
}

@end
