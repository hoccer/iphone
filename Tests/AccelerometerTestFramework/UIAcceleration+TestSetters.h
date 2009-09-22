//
//  UIAcceleration+TestSetters.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIAcceleration (TestSetters) 

+ (UIAcceleration *) accelerationWithX: (float) x y:(float)y z:(float)z timestamp: (float) timestamp;

- (void)setTimestamp: (double)timestamp;
- (void)setX: (double)aX;
- (void)setY: (double)aY;
- (void)setZ: (double)aZ;

@end
