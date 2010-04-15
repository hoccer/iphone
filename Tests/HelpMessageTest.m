//
//  HelpMessageTest.m
//  Hoccer
//
//  Created by Robert Palmer on 15.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HelpMessageTest.h"
#import "HoccerMessageResolver.h"
#import "HocLocation.h"

#define kGoodAccuracy 199 // good accuracy is better than 200m 
#define kBadAccuracy 501 // bad accuracy is worse than 500m
#define kVeryVeryBadAccuracy 5001 // to bad! worse than 5000m  

@implementation HelpMessageTest

- (void) testItShouldBeCreatable {
	HoccerMessageResolver *errorResolver = [[HoccerMessageResolver alloc] init];

	STAssertNotNil(errorResolver, @"HoccerMessageResolver should be created");
}

- (void) testItShouldReturnImpreciseMessageWhenLocationIsBad {
	HoccerMessageResolver *errorResolver = [[HoccerMessageResolver alloc] init];
	HocLocation *hocLocation = [[HocLocation alloc] initWithLocation:[self locationWithAccuracy:kBadAccuracy] bssids:nil];
	
	NSError* message = [errorResolver messageForLocationInformation: hocLocation];
	STAssertEquals([message code], kHoccerMessageImpreciseLocation, @"return code should be 'impreciseLocation'");
	
	[hocLocation release];
	[errorResolver release];
}

- (void) testItShouldReturnNilWhenLocationIsGood {
	HoccerMessageResolver *errorResolver = [[HoccerMessageResolver alloc] init];
	HocLocation *hocLocation = [[HocLocation alloc] initWithLocation:[self locationWithAccuracy:kGoodAccuracy] bssids:nil];
	
	NSError* message = [errorResolver messageForLocationInformation: hocLocation];
	STAssertNil(message, @"should return no message");
	
	[hocLocation release];
	[errorResolver release];
}

- (void) testItShouldReturnNeedsCatcherMessageWhenLocationIsGoodAndNoCatcher {
	HoccerMessageResolver *errorResolver = [[HoccerMessageResolver alloc] init];
	HocLocation *hocLocation = [[HocLocation alloc] initWithLocation:[self locationWithAccuracy:kGoodAccuracy] bssids:nil];
	
	NSError* message = [errorResolver messageForLocationInformation: hocLocation event: @"throw"];
	STAssertEquals([message code], kHoccerMessageNoCatcher, @"return code should be 'noCatcher'");
	
	[hocLocation release];
	[errorResolver release];
}

- (void) testItShouldReturnNeedsCatcherMessageWhenLocationIsGoodAndNoThrower {
	HoccerMessageResolver *errorResolver = [[HoccerMessageResolver alloc] init];
	HocLocation *hocLocation = [[HocLocation alloc] initWithLocation:[self locationWithAccuracy:kGoodAccuracy] bssids:nil];
	
	NSError* message = [errorResolver messageForLocationInformation: hocLocation event: @"catch"];
	STAssertEquals([message code], kHoccerMessageNoThrower, @"return code should be 'noThrower'");
	
	[hocLocation release];
	[errorResolver release];
}

- (void) testItShouldReturnNeedsSecondSweeperMessageWhenLocationIsGoodAndSweepIn {
	HoccerMessageResolver *errorResolver = [[HoccerMessageResolver alloc] init];
	HocLocation *hocLocation = [[HocLocation alloc] initWithLocation:[self locationWithAccuracy:kGoodAccuracy] bssids:nil];
	
	NSError* message = [errorResolver messageForLocationInformation: hocLocation event: @"sweepIn"];
	STAssertEquals([message code], kHoccerMessageNoSecondSweeper, @"return code should be 'noSecongSweeper'");
	
	[hocLocation release];
	[errorResolver release];
}


- (CLLocation *)locationWithAccuracy: (float)accuracy {
	
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 14;
	coordinate.longitude = 23;
	
	CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:1 horizontalAccuracy:accuracy verticalAccuracy:100 timestamp:[NSDate date]];

	return [location autorelease];
}

@end
