//
//  UIAcceleration+TestSetters.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "UIAcceleration+TestSetters.h"


@implementation UIAcceleration (TestSetters)

+ (UIAcceleration *) accelerationWithX: (float) x y:(float)y z:(float)z timestamp: (float) timestamp
{
	UIAcceleration *acceleration = [[UIAcceleration alloc] init];
	acceleration.x = x;
	acceleration.y = y;
	acceleration.z = z;
	acceleration.timestamp = timestamp;
	
	return [acceleration autorelease];
}

- (void)setTimestamp: (double)aTimestamp 
{
	timestamp = aTimestamp;
}

- (void)setX: (double)aX 
{
	x = aX;
}

- (void)setY: (double)aY 
{
	y = aY;
}

- (void)setZ: (double)aZ
{
	z = aZ;
}

@end
