//
//  AccelerationRecorderTests.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Dependent unit tests mean unit test code depends on an application to be injected into.
//  Setting this to 0 means the unit test code is designed to be linked into an independent executable.

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "AccelerationRecorder.h"


@interface AccelerationRecorderTests : SenTestCase {

}

- (void)testAccelerationRecorder;

@end
