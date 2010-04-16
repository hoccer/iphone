//
//  HelpMessageTest.m
//  Hoccer
//
//  Created by Robert Palmer on 15.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LocationControllerTest.h"
#import "HocLocation.h"
#import "LocationController.h"
#import "HocItemData.h"
#import "NSString+Regexp.h"

#define kGoodAccuracy 199 // good accuracy is better than 200m 
#define kBadAccuracy 501 // bad accuracy is worse than 500m
#define kVeryBadAccuracy 2001 // to bad! worse than 2000m  

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
	STAssertEquals([message code], kHoccerImpreciseLocation, @"return code should be 'impreciseLocation'");
	
	[locationController release];
}

- (void) testItShouldReturnNoMessageIfLocationIsAccurate {
	LocationController *locationController = [[LocationController alloc] init];
	[locationController locationManager:[[CLLocationManager alloc] init] didUpdateToLocation:[self locationWithAccuracy:kGoodAccuracy] fromLocation:nil];
	
	NSError* message = [locationController messageForLocationInformation];
	
	STAssertNil(message, @"message should not be created");	
	[locationController release];
}

- (void) testItShouldReturnBadLocationInformationWhenNoLocationIsAvailable {
	LocationController *locationController = [[LocationController alloc] init];

	NSError* message = [locationController messageForLocationInformation];
	
	STAssertNotNil(message, @"message should be created");
	STAssertEquals([message code], kHoccerBadLocation, @"return code should be 'badLocation'");

	[locationController release];
}

- (void) testItShouldReturnBadLocationInformationWhenLocationAccuracyIsVeryBad {
	LocationController *locationController = [[LocationController alloc] init];
	[locationController locationManager:[[CLLocationManager alloc] init] didUpdateToLocation:[self locationWithAccuracy:kVeryBadAccuracy] fromLocation:nil];

	NSError* message = [locationController messageForLocationInformation];
	
	STAssertNotNil(message, @"message should be created");
	STAssertEquals([message code], kHoccerBadLocation, @"return code should be 'badLocation'");
	
	[locationController release];
}

- (void)testItShouldGenerateRecoverySuggestionIncludingWifiWhenBSSIDSAreNotAvailable {
	LocationController *locationController = [[LocationController alloc] init];
	[locationController locationManager:[[CLLocationManager alloc] init] didUpdateToLocation:[self locationWithAccuracy:kVeryBadAccuracy] fromLocation:nil];
	
	NSError* message = [locationController messageForLocationInformation];
	
	STAssertNotNil([message localizedRecoverySuggestion], @"message should contain recovery suggestion");
	STAssertTrue([[message localizedRecoverySuggestion] contains:@"wifi"], @"message should contain wifi");
	
	[locationController release];
}

- (void)testItShouldGenerateRecoverySuggestionWithoutWifiWhenBSSIDSAreAvailable {
	LocationController *locationController = [[LocationController alloc] init];
	[locationController locationManager:[[CLLocationManager alloc] init] didUpdateToLocation:[self locationWithAccuracy:kVeryBadAccuracy] fromLocation:nil];
	locationController.bssids = [NSArray arrayWithObjects:@"1234567890", nil];
	
	NSError* message = [locationController messageForLocationInformation];
	STAssertNotNil([message localizedRecoverySuggestion], @"message should contain recovery suggestion");
	STAssertFalse([[message localizedRecoverySuggestion] contains:@"wifi"], @"message should not contain wifi");
	
	[locationController release];
}

- (void)testItShouldGenerateRecoverySuggestionWithGoOutsideWhenLocationIsBad {
	LocationController *locationController = [[LocationController alloc] init];
	[locationController locationManager:[[CLLocationManager alloc] init] didUpdateToLocation:[self locationWithAccuracy:kBadAccuracy] fromLocation:nil];
	locationController.bssids = [NSArray arrayWithObjects:@"1234567890", nil];
	
	NSError* message = [locationController messageForLocationInformation];
	STAssertNotNil([message localizedRecoverySuggestion], @"message should contain recovery suggestion");
	STAssertTrue([[message localizedRecoverySuggestion] contains:@"going
				  outside"], @"message should contain go outside hint");
	
	[locationController release];
}


- (CLLocation *)locationWithAccuracy: (float)accuracy {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 14;
	coordinate.longitude = 23;
	
	CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:1 horizontalAccuracy:accuracy verticalAccuracy:100 timestamp:[NSDate date]];

	return [location autorelease];
}

@end
