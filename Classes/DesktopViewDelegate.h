//
//  DesktopViewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DesktopView;

@protocol DesktopViewDelegate <NSObject>

- (BOOL)desktopView: (DesktopView *)desktopView needsEmptyViewAtPoint: (CGPoint)point;

@optional
- (void)desktopView: (DesktopView *)desktopView didSweepOutView: (UIView *)view;
- (void)desktopView: (DesktopView *)desktopView didSweepInView: (UIView *)view;
- (void)desktopView:(DesktopView *)desktopView didRemoveViewAtIndex: (NSInteger)view;

@end
