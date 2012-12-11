//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright Hoccer GmbH 2009. All rights reserved.
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
#import "NSData_Base64Extensions.h"

@interface HoccerAppDelegate ()
- (void)userNeedToAgreeToTermsOfUse;
- (BOOL)handleHoccerURL: (NSURL *)url;
- (BOOL)handleFileURL: (NSURL *)url;
@end


@implementation HoccerAppDelegate

@synthesize networkReachable;
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	((HoccerAppDelegate *)info).networkReachable = (flags & kSCNetworkReachabilityFlagsReachable);
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"NetworkConnectionChanged" object:info];
}

@synthesize window;
@synthesize viewController;
@synthesize channelMode;

- (BOOL)channelMode
{
    NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
    if ((channel != nil) && (channel.length > 0)) {
        return YES;
    }
    return NO;
}

//########

+ (void)initialize
{
    NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	
    NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithContentsOfFile: filepath];
    [defaults setObject:[UIDevice currentDevice].name forKey:@"clientName"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationSupportsShakeToEdit = NO;
	application.idleTimerDisabled = NO;
   
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"encryptionInit"]){
        [[RSA sharedInstance] cleanKeyChain];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"encryptionInit"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[RSA sharedInstance] genRandomString:64];
    
	//[window addSubview:viewController.view];
    window.rootViewController = viewController;
	[window makeKeyAndVisible];
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        startAnimation = [[StartAnimationiPhoneViewController alloc] initWithNibName:@"StartAnimationiPhoneViewController" bundle:[NSBundle mainBundle]];
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        [startAnimation.view setFrame:CGRectMake(0, 20, screenFrame.size.width, screenFrame.size.height-20)];
        [window addSubview:startAnimation.view];
    }
	//SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [@"http://wolke.hoccer.com" UTF8String]);
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [@"http://www.hoccer.com" UTF8String]);
	if (reachability == NULL) {
		//NSLog(@"could not create reachability ref");
		return YES;
	}
	
	SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
	if (!SCNetworkReachabilitySetCallback(reachability, ReachabilityCallback, &context)) {
		//NSLog(@"could not add callback");
		return YES;
	}
	
	if (!SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
		//NSLog(@"could not add to run loop");
		return YES;
	}
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"selected_clients"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//[TestFlight takeOff:@"67055e64e1b65aed68c6fa79120286a3_OTg4NjIwMTItMDMtMDcgMDU6MDk6NDYuOTM5Mzc0"];

    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]){
        
        if ([[[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] scheme] isEqualToString:@"hoccer"]) {
            //NSLog(@"AppDelegate application: didFinishLaunchingWithOptions: url= #%@#", [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]);
            return [self handleHoccerURL:[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]];
        }
        
        if ([[[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] scheme] isEqualToString:@"hoccerchannel"]) {
            //NSLog(@"AppDelegate application: didFinishLaunchingWithOptions: url= #%@#", [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]);
            return [self handleHoccerURL:[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]];
        }
        
        if ([[[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] scheme] isEqualToString:@"file"]) {
            return [self handleFileURL:[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]];
        }
    }
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"renewPubKey"]){
//        [[RSA sharedInstance] generateKeyPairKeys];
//    }
    
  //  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
    
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        UIImage *backButton = [[UIImage imageNamed:@"nav_bar_btn_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 6)];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
            [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"hoccer_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 2, 20, 2)] forBarMetrics:UIBarMetricsDefault];
            UIImage *defaultButton = [[UIImage imageNamed:@"nav_bar_btn_default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
            [[UIBarButtonItem appearance] setBackgroundImage:defaultButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        }
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {
		return NO;
	}
    if ([[url scheme] isEqualToString:@"hoccer"]) {
        //NSLog(@"AppDelegate application: handleOpenURL: url= #%@#", url);

        return [self handleHoccerURL:url];
    }
    if ([[url scheme] isEqualToString:@"hoccerchannel"]) {
        //NSLog(@"AppDelegate application: handleOpenURL: url= #%@#", url);

        return [self handleHoccerURL:url];
    }
    
    if ([[url scheme] isEqualToString:@"file"]) {
        return [self handleFileURL:url];
    }
	return NO;
}

- (BOOL)handleHoccerURL: (NSURL *)url
{
    NSString *urlString = [url absoluteString];
	NSRange colon = [urlString rangeOfString:@":"];
	NSString *content = [urlString substringFromIndex:(colon.location + 1)];
    
    //NSLog(@"AppDelegate url scheme - url: #%@#", urlString);
    //NSLog(@"AppDelegate url scheme - content: #%@#", content);
    if ([content startsWith:@"//channel/"]) {
        
        NSString *channelName = [content substringFromIndex:(10)];

        if ((channelName != nil) && (channelName.length > 0)) {
            //NSLog(@"AppDelegate url scheme - use channelName: #%@#", channelName);
        }
        else {
            //NSLog(@"AppDelegate no channel parsed - channelName: #%@#", channelName);
            channelName = @"3xF4rY2lKj";
        }
        [[NSUserDefaults standardUserDefaults] setObject:channelName forKey:@"channel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSNotification *notification = [NSNotification notificationWithName:@"startChannelAutoReceiveMode" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    else {
        //NSLog(@"AppDelegate url scheme - no channel: #%@#", content);

        HoccerText *contentView = [[[HoccerText alloc] initWithData:[content dataUsingEncoding: NSUTF8StringEncoding]] autorelease];
        [viewController setContentPreview: contentView];
    }
    return YES;
}

- (BOOL)handleFileURL: (NSURL *)url
{
    NSString *fileName = [url lastPathComponent];
    NSString *destPath = [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:fileName];
    NSURL *destURL = [NSURL fileURLWithPath:destPath];
    NSError *error = nil;
    
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:destURL error:&error];

    if (error != nil) {
        //NSLog(@"error %@", error);
        return NO;
    }
    [viewController setContentPreview:[[[HoccerFileContent alloc] initWithFilename:fileName] autorelease]];
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //NSLog(@"devToken=%@",[deviceToken asBase64EncodedString]);
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[deviceToken asBase64EncodedString]] forKey:@"apnToken"];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [viewController.linccer reactivate];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [viewController.linccer disconnect];
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

- (void)dealloc
{
    [viewController release];
	[window release];
	
	[super dealloc];
}

@end
