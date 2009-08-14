//
//  UITestAppDelegate.m
//  UITest
//
//  Created by david on 14.08.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "UITestAppDelegate.h"
#import "MyViewController.h"

@implementation UITestAppDelegate

@synthesize window;
@synthesize myViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	MyViewController *aViewController = [[MyViewController alloc]
										 initWithNibName:@"MyViewController" bundle:[NSBundle mainBundle]];
	[self setMyViewController:aViewController];
	// XXX ??? self.myViewController = aViewController;
	[aViewController release];
	
	[window addSubview:[myViewController view]];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[myViewController release];
    [window release];
    [super dealloc];
}


@end
