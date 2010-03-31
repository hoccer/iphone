//
//  DesktopViewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DesktopViewController;

@protocol DesktopViewDelegate

- (void)desktopView: (DesktopViewController *)desktopView needsEmptyViewAtPoint: (CGPoint)point;

@optional
- (void)desktopView: (DesktopViewController *)desktopView didSweepOutView: (UIView *)view;
- (void)desktopView: (DesktopViewController *)desktopView didSweepInView: (UIView *)view;

@end
