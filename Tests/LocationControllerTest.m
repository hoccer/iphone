//
//  HelpMessageTest.m
//  Hoccer
//
//  Created by Robert Palmer on 15.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LocationControllerTest.h"
#import "HoccerMessageResolver.h"
#import "HocLocation.h"
#import "LocationController.h"

#define kGoodAccuracy 199 // good accuracy is better than 200m 
#define kBadAccuracy 501 // bad accuracy is worse than 500m
#define kVeryBadAccuracy 5001 // to bad! worse than 5000m  

@implementation LocationControllerTest

- (void) testLocationControllerShouldBeCreatable {
	LocationController *locationController = [[LocationController alloc] init];
	
	STAssertNotNil(locationController, @"location controller should be created");
	[locationController release];
}

- (void) testItShouldReturnImpreciseLocationMessageWhenTheLocationAccuracyIsBad {
	LocationController *locationController = [[LocationController alloc] init];
	[locationController locationManager:[[CLLocationManager alloc] init] didUpdateToLocation:[self locationWithAccuracy:kBadAccuracy] fromLocation:nil];
	
	NSError* message = [locationController messageForLocationInformation];
	
	STAssertNotNil(message, @"message should be created");
	STAssertEquals([message code], kHoccerMessageImpreciseLocation, @"return code should be 'impreciseLocation'");
	
	[locationController release];
}

- (void) testItShouldReturnNoMessageIfLocationIsAccurate {
	LocationController *locationController = [[LocationController alloc] init];
	[locationController locationManager:[[CLLocationManager alloc] init] didUpdateToLocation:[self locationWithAccuracy:kGoodAccuracy] fromLocation:nil];
	
	NSError* message = [locationController messageForLocationInformation];
	
	STAssertNil(message, @"message should be created");	
	[locationController release];
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
