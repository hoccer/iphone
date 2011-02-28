//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>

#import "HoccerAppDelegate.h"
#import "HoccerViewController.h"
#import "TermOfUse.h"
#import "StatusViewController.h"
#import "HoccerText.h"

#import "HistoryData.h"
#import "NSString+Regexp.h"


@interface HoccerAppDelegate ()
- (void)userNeedToAgreeToTermsOfUse;
@end


@implementation HoccerAppDelegate

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"NetworkConnectionChanged" object:info];
}

@synthesize window;
@synthesize viewController;


+ (void)initialize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"AdFree"];
	
    [defaults registerDefaults:appDefaults];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	application.applicationSupportsShakeToEdit = NO;
	application.idleTimerDisabled = YES;
	
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [@"http://api.hoccer.com" UTF8String]);
	if (reachability == NULL) {
		NSLog(@"could not create reachability ref");
		return;
	}
	
	SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
	if (!SCNetworkReachabilitySetCallback(reachability, ReachabilityCallback, &context)) {
		NSLog(@"could not add callback");
		return;
	}
	
	if (!SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
		NSLog(@"could not add to run loop");
		return;
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL: (NSURL *)url {
	if (!url) {
		return NO;
	}

	NSString *urlString = [url absoluteString];
	NSRange colon = [urlString rangeOfString:@":"];
	NSString *content = [urlString substringFromIndex:(colon.location + 1)];
	[viewController setContentPreview:[[HoccerText alloc] initWithData:[content dataUsingEncoding: NSUTF8StringEncoding]]];

	return YES;
}

- (void)applicationWillTerminate: (UIApplication *)application {
}

- (void)dealloc {	
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

@end
