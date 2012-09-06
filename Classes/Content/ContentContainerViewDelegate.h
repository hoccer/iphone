//
//  ContentContainerViewDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContentContainerView;

@protocol ContentContainerViewDelegate <NSObject>

- (void)containerView:(ContentContainerView *)view didMoveToPosition:(CGPoint)point;

@end
