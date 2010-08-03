//
//  HoccerContentIPhonePreviewDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerContentIPhonePreviewDelegate.h"
#import "ReceivedContentViewController.h"


@implementation HoccerContentIPhonePreviewDelegate
@synthesize viewController;

- (void)hoccerContent: (HoccerContent*)hoccerContent previewInViewController: (UIViewController *) aViewController {
	self.viewController = aViewController;
	
	ReceivedContentViewController *receivedContentViewController = [[ReceivedContentViewController alloc] initWithNibName:@"ReceivedContentView" bundle:nil];
	
	receivedContentViewController.delegate = self;
	[receivedContentViewController setHoccerContent: hoccerContent];
	
	//[self.viewController presentModalViewController: receivedContentViewController animated:YES];	
	[(UINavigationController *) self.viewController pushViewController:receivedContentViewController animated:YES];
	[receivedContentViewController release];
}

- (void)hoccerContent: (HoccerContent*)hoccerContent decorateViewWithGestureRecognition: (UIView *)view inViewController: (UIViewController *)viewController {

}

- (void)receivedViewContentControllerDidFinish:(ReceivedContentViewController *)controller {
	[self.viewController dismissModalViewControllerAnimated:YES];
}

- (UIImage *)hoccerContentIcon: (HoccerContent *)hoccerContent {
	return nil;
}

@end
