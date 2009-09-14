//
//  MockedAccelerometerDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MockedAccelerometerDelegate : NSObject <UIAccelerometerDelegate> {
	NSInteger accelerationsCount;
}

@property (readonly) NSInteger accelerationsCount;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;

@end
