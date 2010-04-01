//
//  HoccerContentIPadPreviewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 30.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HoccerContent;


@interface HoccerContentIPadPreviewDelegate : NSObject <UIDocumentInteractionControllerDelegate> {
	UIViewController *viewControllerForPreview;
	
	UIDocumentInteractionController *interactionController;
}

@property (retain) UIDocumentInteractionController *interactionController;

- (void)hoccerContent: (HoccerContent*)hoccerContent previewInViewController: (UIViewController *) viewController;
- (void)hoccerContent: (HoccerContent*)hoccerContent decorateViewWithGestureRecognition: (UIView *)view inViewController: (UIViewController *)viewController;
- (UIImage *)hoccerContentIcon: (HoccerContent *)hoccerContent;


@end
