//
//  LocationController.m
//  Hoccer
//
//  Created by Robert Palmer on 16.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LocationController.h"
#import "WifiScanner.h"
#import "HocLocation.h"

@implementation LocationController
@synthesize viewController;
@synthesize lastLocationUpdate;

- (id) init
{
	self = [super init];
	if (self != nil) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
		
		[WifiScanner sharedScanner];
	}
	
	return self;
}

- (void) dealloc
{
	[locationManager stopUpdatingLocation];
	[locationManager release];
	[viewController release];
	
	[super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation {
	
	if ([[NSDate date] timeIntervalSinceDate: lastLocationUpdate] < 10)
		return;
	
	MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate: newLocation.coordinate];
	geocoder.delegate = self;
	
	[geocoder start];
	
	self.lastLocationUpdate = [NSDate date];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	[geocoder release];
	CLLocation *location = locationManager.location;
	
	[viewController setLocation:placemark withAccuracy: location.horizontalAccuracy];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError: (NSError *)error
{
}

- (HocLocation *)location {
	return [[[HocLocation alloc] 
			initWithLocation: locationManager.location
					  bssids:[WifiScanner sharedScanner].bssids] autorelease];
}



@end
