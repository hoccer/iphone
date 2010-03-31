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

#import "FeedbackProvider.h"

#import "TermOfUse.h"

#import "HocLocation.h"
#import "LocationController.h"

#import "StatusViewController.h"

#import "Preview.h"

@interface HoccerAppDelegate ()
- (void)userNeedToAgreeToTermsOfUse;
@end


@implementation HoccerAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize statusViewController;


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
}

- (void)dealloc {			
	[statusViewController release];
    [viewController release];
	[window release];
	
	[super dealloc];
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
#pragma mark StatusViewController Delegate

- (void)statusViewControllerDidCancelRequest:(StatusViewController *)controller {
	[viewController resetPreview];
	
	viewController.allowSweepGesture = YES;
	
	[statusViewController hideActivityInfo];
}

@end
