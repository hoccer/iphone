//
//  ContentContainerViewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContentContainerView;

@protocol ContentContainerViewDelegate

- (void)containerView:(ContentContainerView *)view didMoveToPosition:(CGPoint)point;
- (void)containerViewDidClose:(ContentContainerView *)view;

- (void)containerViewDidSweepOut: (ContentContainerView *)view;

@end
