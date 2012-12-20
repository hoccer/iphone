//
//  PullDownViewDelegate.h
//  Hoccer
//
//  Created by Ralph on 18.12.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PullDownView;

@protocol PullDownViewDelegate <NSObject>

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
