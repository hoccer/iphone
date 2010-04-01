//
//  HoccerContentIPadPreviewDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 30.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerContentIPadPreviewDelegate.h"
#import "HoccerContent.h"

@interface HoccerContentIPadPreviewDelegate ()

@property (retain) UIViewController *viewControllerForPreview;

- (void)createInteractionControllerForFile: (NSURL *)fileURL;

@end

@implementation HoccerContentIPadPreviewDelegate

@synthesize interactionController;
@synthesize viewControllerForPreview;

- (void)hoccerContent: (HoccerContent*)hoccerContent previewInViewController: (UIViewController *) viewController {
	[self createInteractionControllerForFile:hoccerContent.fileUrl];
	self.viewControllerForPreview = viewController;
	
	[self.interactionController presentPreviewAnimated:YES];
}

- (void)hoccerContent: (HoccerContent*)hoccerContent decorateViewWithGestureRecognition: (UIView *)view inViewController: (UIViewController *)viewController {
	[self createInteractionControllerForFile:hoccerContent.fileUrl];
	self.viewControllerForPreview = viewController;
	
	for (UIGestureRecognizer *recognizer in self.interactionController.gestureRecognizers) {
		[view addGestureRecognizer:recognizer];
	} 
}

- (UIImage *)hoccerContentIcon: (HoccerContent *)hoccerContent {
	[self createInteractionControllerForFile:hoccerContent.fileUrl];
	
	return [self.interactionController.icons objectAtIndex:0];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return viewControllerForPreview;
}


- (void)createInteractionControllerForFile: (NSURL *)fileURL {
	if (self.interactionController == nil) {
		
		self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
		self.interactionController.delegate = self;	
	}
}

- (void) dealloc
{
	[interactionController release];
	[viewControllerForPreview release];
	 
	[super dealloc];
}



@end
