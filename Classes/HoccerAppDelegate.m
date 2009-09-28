//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "HoccerAppDelegate.h"
#import "HoccerViewController.h"

@implementation HoccerAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize dataToSend;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	// Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];

    [super dealloc];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)aViewController
{
	NSLog(@"selected class: %@", aViewController);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.dataToSend =  UIImagePNGRepresentation([info objectForKey: UIImagePickerControllerOriginalImage]);
}

@end
