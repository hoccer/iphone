//
//  HoccerContentIPadPreviewDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 30.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerContentIPadPreviewDelegate.h"
#import "HoccerContent.h"

@implementation HoccerContentIPadPreviewDelegate
@synthesize interactionController;

- (void)hoccerContent: (HoccerContent*)hoccerContent previewInViewController: (UIViewController *) viewController {
	if (self.interactionController == nil) {
		viewControllerForPreview = [viewController retain];
		
		self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:hoccerContent.fileUrl];
		self.interactionController.delegate = self;	
	}
	
	[self.interactionController presentPreviewAnimated:YES];
}

- (void)hoccerContent: (HoccerContent*)hoccerContent decorateViewWithGestureRecognition: (UIView *)view inViewController: (UIViewController *)viewController {
	if (self.interactionController == nil) {
		viewControllerForPreview = [viewController retain];

		self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:hoccerContent.fileUrl];
		self.interactionController.delegate = self;	
	}

	for (UIGestureRecognizer *recognizer in self.interactionController.gestureRecognizers) {
		[view addGestureRecognizer:recognizer];
	} 
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return viewControllerForPreview;
}

@end
