//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <YAJLiOS/YAJL.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AddressBookUI/AddressBookUI.h>

#import "HoccerAppDelegate.h"
#import "HoccerViewController.h"
#import "TermOfUse.h"
#import "StatusViewController.h"
#import "HoccerText.h"
#import "HoccerFileContent.h"

#import "HistoryData.h"
#import "NSString+Regexp.h"
#import "NSFileManager+FileHelper.h"
#import "RSA.h"

@interface HoccerAppDelegate ()
- (void)userNeedToAgreeToTermsOfUse;
- (BOOL)handleHoccerURL: (NSURL *)url;
- (BOOL)handleFileURL: (NSURL *)url;
@end


@implementation HoccerAppDelegate
@synthesize networkReachable;

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
	((HoccerAppDelegate *)info).networkReachable = (flags & kSCNetworkReachabilityFlagsReachable);
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"NetworkConnectionChanged" object:info];
}

@synthesize window;
@synthesize viewController;


+ (void)initialize {
    NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	
    NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithContentsOfFile: filepath];
    [defaults setObject:[UIDevice currentDevice].name forKey:@"clientName"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
 
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    application.applicationSupportsShakeToEdit = NO;
	application.idleTimerDisabled = NO;
   
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"encryptionInit"]){
        [[RSA sharedInstance] cleanKeyChain];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"encryptionInit"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[RSA sharedInstance] genRandomString:64];
    
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
    	

	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [@"http://wolke.hoccer.com" UTF8String]);
	if (reachability == NULL) {
		NSLog(@"could not create reachability ref");
		return YES;
	}
	
	SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
	if (!SCNetworkReachabilitySetCallback(reachability, ReachabilityCallback, &context)) {
		NSLog(@"could not add callback");
		return YES;
	}
	
	if (!SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
		NSLog(@"could not add to run loop");
		return YES;
	}
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"selected_clients"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /*
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"renewPubKey"]){
        [[RSA sharedInstance] generateKeyPairKeys];
    }
    */
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (!url) {
		return NO;
	}
    
    if ([[url scheme] isEqualToString:@"hoccer"]) {
        return [self handleHoccerURL:url];
    }
    
    if ([[url scheme] isEqualToString:@"file"]) {
        return [self handleFileURL:url];
    }
    
	return NO;
}

- (BOOL)handleHoccerURL: (NSURL *)url {
    NSString *urlString = [url absoluteString];
	NSRange colon = [urlString rangeOfString:@":"];
	NSString *content = [urlString substringFromIndex:(colon.location + 1)];
    HoccerText *contentView = [[[HoccerText alloc] initWithData:[content dataUsingEncoding: NSUTF8StringEncoding]] autorelease];
	[viewController setContentPreview: contentView];
    
    return YES;
}

- (BOOL)handleFileURL: (NSURL *)url {    
    NSString *fileName = [url lastPathComponent];
    NSString *destPath = [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:fileName];
    NSURL *destURL = [NSURL fileURLWithPath:destPath];
    NSError *error = nil;
    
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:destURL error:&error];

    if (error != nil) {
        NSLog(@"error %@", error);
        return NO;
    }
    [viewController setContentPreview:[[[HoccerFileContent alloc] initWithFilename:fileName] autorelease]];
    
    return YES;
}
     
- (void)applicationDidBecomeActive: (UIApplication *)application {
    [viewController.linccer reactivate];
}


- (void)applicationWillResignActive:(UIApplication *)application {    
    [viewController.linccer disconnect];
}

#pragma mark Terms Of Use Delegate Methods
- (void)userNeedToAgreeToTermsOfUse {
	TermOfUse *terms = [[TermOfUse alloc] init];
	
	terms.delegate = self;
	[viewController presentModalViewController:terms animated:NO];
	
	[terms release];
}

- (void)userDidAgreeToTermsOfUse {
	[viewController dismissModalViewControllerAnimated:YES];
	
	CFBooleanRef agreed = kCFBooleanTrue;
	CFPreferencesSetAppValue(CFSTR("termsOfUse"), agreed, CFSTR("com.artcom.Hoccer"));

	CFPreferencesAppSynchronize(CFSTR("com.artcom.Hoccer"));
}

- (void)dealloc {	
    [viewController release];
	[window release];
	
	[super dealloc];
}

@end
