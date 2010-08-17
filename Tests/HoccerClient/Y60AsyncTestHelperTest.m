//
//  Y60AsyncTestHelperTest.m
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "GHUnit.h"
#import "Y60AsyncTestHelper.h"


@interface Y60AsyncTestHelperTest : GHAsyncTestCase {
	NSInteger value;
}

@property (assign) NSInteger value;
@end


@implementation Y60AsyncTestHelperTest
@synthesize value;

- (void)setUp {
	self.value = 0;
}

- (void)testItReturnYesIfPropertyValueDoesChangeToRightValueInDefinedTime {
	[self prepare];
	
	
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(_success) userInfo:nil repeats:NO];
	// [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	
	// GHAssertTrue([Y60AsyncTestHelper waitForTarget: self selector: @selector(value) toBecome: 10 atLeast: 1], @"it should return yes");
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1];
}

- (void)_success {
	[self notify:kGHUnitWaitStatusSuccess];
	
}

- (void)testItReturnNoIfPropertyValueDoesNotChangeToRightValueInDefinedTime {
	NSTimer *timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(changeValue) userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

	GHAssertFalse([Y60AsyncTestHelper waitForTarget: self selector: @selector(value) toBecome: 6 atLeast: 1], @"it should return no");
}

- (void)testItReturnNoIfPropertyDoesChangeToRightValueAfterDefinedTime {
	NSTimer *timer = [NSTimer timerWithTimeInterval:1.3 target:self selector:@selector(changeValue) userInfo:nil repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	
	GHAssertFalse([Y60AsyncTestHelper waitForTarget: self selector: @selector(value) toBecome: 10 atLeast: 1], @"it should return no");
}

- (void)changeValue {
	self.value = 10;
}


@end
