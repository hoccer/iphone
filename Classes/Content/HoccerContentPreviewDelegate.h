//
//  HoccerContentPreviewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 06.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerContent;

@protocol HoccerContentPreviewDelegate <NSObject>

- (void)hoccerContent: (HoccerContent*)hoccerContent previewInViewController: (UIViewController *) viewController;
- (void)hoccerContent: (HoccerContent*)hoccerContent decorateViewWithGestureRecognition: (UIView *)view inViewController: (UIViewController *)viewController;
- (UIImage *)hoccerContentIcon: (HoccerContent *)hoccerContent;

@end
