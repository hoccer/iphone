//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "HoccerAppDelegate.h"
#import "HoccerViewController.h"
#import "ReceivedContentViewController.h"

#import "BaseHoccerRequest.h"

#import "HoccerDownloadRequest.h"
#import "HoccerUploadRequest.h"
#import "GesturesInterpreter.h"

#import "HoccerContentFactory.h"
#import "HoccerUrl.h"
#import "HoccerContent.h"
#import "HoccerData.h"

#import "FeedbackProvider.h"

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

@synthesize locationController;
@synthesize statusViewController;

@synthesize gestureInterpreter;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	application.applicationSupportsShakeToEdit = NO;
	application.idleTimerDisabled = YES;
	
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
	[viewController.view insertSubview:statusViewController.view atIndex:1];

	CFBooleanRef agreedToTermsOfUse = (CFBooleanRef)CFPreferencesCopyAppValue(CFSTR("termsOfUse"), CFSTR("com.artcom.Hoccer"));
	if (agreedToTermsOfUse == NULL) {
		[self userNeedToAgreeToTermsOfUse];
	}
	
	if (agreedToTermsOfUse != NULL) CFRelease(agreedToTermsOfUse);
	
	contentOnDesktop = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)dealloc {	
	[contentToSend release];
	[contentOnDesktop release];
	[request release];
	
	[gestureInterpreter release];
	[locationController release];
	
	[statusViewController release];
    [viewController release];
	[window release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark GesturesInterpreter Delegate Methods

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter {
	if (self.contentToSend || request != nil) {
		return;
	}
	viewController.allowSweepGesture = NO;

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
	viewController.allowSweepGesture = NO;
	
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
//	if ([HoccerContentFactory isSupportedType: [aRequest.response MIMEType]])
//		return;
//	
//	[aRequest cancel];
//	
//	NSURL *url = [aRequest.request URL];
//	self.hoccerContent = [[HoccerUrl alloc] initWithData: [[url absoluteString] dataUsingEncoding: NSUTF8StringEncoding]];
//	
//	receivedContentView = [[ReceivedContentView alloc] initWithNibName:@"ReceivedContentView" bundle:nil];
//	
//	receivedContentView.delegate = self;
//	[receivedContentView setHoccerContent: self.hoccerContent];
//	
//	[viewController presentModalViewController: receivedContentView animated:YES];
//	
//	[request release];
//	request = nil;
//	
//	[statusViewController hideActivityInfo];
}

- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest
{
	id <HoccerContent> hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: aRequest.response 
														    withData: aRequest.result];
		
	[viewController presentReceivedContent: hoccerContent];

	[request release];
	request = nil;

	[statusViewController hideActivityInfo];
	[contentOnDesktop addObject: hoccerContent];
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
	[statusViewController setError: [error localizedDescription]];
	[viewController resetPreview];
	[request release];
	request = nil;
	
	if (self.contentToSend == nil) {
		viewController.allowSweepGesture = YES;
	}
	
	// [statusViewController hideActivityInfo];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update 
{
	[statusViewController setUpdate: update];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress
{
	[statusViewController setProgressUpdate:[progress floatValue]];
}

#pragma mark Terms Of Use Delegate Methods
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


#pragma mark -
#pragma mark HoccerViewController Delegate

- (void)hoccerViewController:(HoccerViewController *)controller didSelectContent: (id<HoccerContent>) content {
	self.contentToSend = content;

	gestureInterpreter.delegate = self;
	viewController.allowSweepGesture = NO;
}

- (void)hoccerViewControllerDidDismissSelectedContent:(HoccerViewController *)controller {
	[self.contentToSend contentWillBeDismissed];
	self.contentToSend = nil;
	viewController.allowSweepGesture = YES;
}

- (void)hoccerViewControllerDidShowContentSelector:(HoccerViewController *)controller {
	gestureInterpreter.delegate = nil;
}

- (void)hoccerViewControllerDidCancelContentSelector:(HoccerViewController *)controller {
	gestureInterpreter.delegate = self;
}

- (void)hoccerViewControllerDidShowHelp: (HoccerViewController *)controller {
	gestureInterpreter.delegate = (NSObject *) viewController.helpViewController;

}

- (void)hoccerViewControllerDidCancelHelp: (HoccerViewController *)controller {
	gestureInterpreter.delegate = self;
}

#pragma mark -
#pragma mark StatusViewController Delegate
- (void)statusViewControllerDidCancelRequest:(StatusViewController *)controller {
	[viewController resetPreview];
	
	if (self.contentToSend != nil) {
		viewController.allowSweepGesture = NO;
	} else {
		viewController.allowSweepGesture = YES;
	}
	
	[statusViewController hideActivityInfo];
	
	[request cancel];
	[request release];
	
	request = nil;
}


@end
