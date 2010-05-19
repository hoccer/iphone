//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

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

	CFBooleanRef agreedToTermsOfUse = (CFBooleanRef)CFPreferencesCopyAppValue(CFSTR("termsOfUse"), CFSTR("com.artcom.Hoccer"));
	if (agreedToTermsOfUse == NULL) {
		[self userNeedToAgreeToTermsOfUse];
	}
	
	if (agreedToTermsOfUse != NULL) CFRelease(agreedToTermsOfUse);
	
	[self cleanUp];
}

- (BOOL)application:(UIApplication *)application handleOpenURL: (NSURL *)url {
	if (!url) {
		return NO;
	}

	NSString *urlString = [url absoluteString];
	NSRange colon = [urlString rangeOfString:@":"];
	NSString *request = [urlString substringFromIndex:(colon.location + 1)];
	[viewController setContentPreview:[[HoccerText alloc] initWithData:[request dataUsingEncoding: NSUTF8StringEncoding] filename:@"url.txt"]];

	return YES;
}

- (void)applicationWillTerminate: (UIApplication *)application {
	NSLog(@"will terminate");
}

- (void)dealloc {	
	NSLog(@"dealloc");

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

- (void)cleanUp {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
	
	NSError *error = nil;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryUrl error:&error];
	NSLog(@"files %@", files);
	HistoryData *historyData = [[HistoryData alloc] init];

	for (NSString *file in files) {
		NSString *filepath = [documentsDirectoryUrl stringByAppendingPathComponent:file];
		if (![file contains:@".sqlite"] && ![historyData containsFile: filepath]) {
			error = nil;
			[[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]; 
			NSLog(@"delete file: %@", file);
		}
	}
	[historyData release];

}

@end
