//
//  HoccerClientTestCase.h
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.

#define USE_APPLICATION_UNIT_TEST 1

#import <UIKit/UIKit.h>
#import "GHUnit.h"

@class HocLocation;
@class HoccerContent;
@class MockHoccerConnectionDelegate;


@interface HoccerClientTestCase : GHAsyncTestCase {
	MockHoccerConnectionDelegate *mockedDelegate;

	NSInteger delta;
}

- (HocLocation *)fakeHocLocation;
- (HoccerContent *)fakeContent;

@end
