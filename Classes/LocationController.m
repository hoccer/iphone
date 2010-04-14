//
//  LocationController.m
//  Hoccer
//
//  Created by Robert Palmer on 16.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LocationController.h"
#import "WifiScanner.h"
#import "HocLocation.h"

@interface LocationController ()
- (void)updateHoccability;
@end



@implementation LocationController

@synthesize viewController;
@synthesize lastLocationUpdate;
@synthesize hoccability;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
		
		[WifiScanner sharedScanner];
		[self updateHoccability];
		
		[[WifiScanner sharedScanner] addObserver:self forKeyPath:@"bssids" options:NSKeyValueObservingOptionNew context:nil];
	}
	
	return self;
}

- (void) dealloc {
	[[WifiScanner sharedScanner] removeObserver:self forKeyPath:@"bssids"];
	
	[locationManager stopUpdatingLocation];
	[locationManager release];
	[viewController release];
	
	[super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation {
	NSLog(@"new location accurracy: %f", newLocation.horizontalAccuracy);

	[self updateHoccability];
	if ([[NSDate date] timeIntervalSinceDate: lastLocationUpdate] < 10)
		return;
	
	geocoder = [[MKReverseGeocoder alloc] initWithCoordinate: newLocation.coordinate];
	geocoder.delegate = self;
	
	[geocoder start];
	
	self.lastLocationUpdate = [NSDate date];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)aGeocoder didFindPlacemark: (MKPlacemark *)placemark
{
	[geocoder release];
	geocoder = nil;
	// [viewController setLocation:placemark withAccuracy: locationManager.location.horizontalAccuracy];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError: (NSError *)error
{
}

- (HocLocation *)location {
	return [[[HocLocation alloc] 
			 initWithLocation: locationManager.location bssids:[WifiScanner sharedScanner].bssids] autorelease];
}

- (BOOL)hasLocation {
	return (locationManager.location.horizontalAccuracy != 0);
}

- (BOOL)hasBSSID {
	return [[WifiScanner sharedScanner].bssids count] != 0;
}

- (void)updateHoccability {
	if ([self hasLocation]) {
		if (locationManager.location.horizontalAccuracy < 100) {
			self.hoccability = 2;
		} else if (locationManager.location.horizontalAccuracy < 1000) {
			self.hoccability = 1;
		}
	}

	if ([self hasBSSID]) {
		self.hoccability += 1;
	}
	
	if ([delegate respondsToSelector:@selector(locationControllerDidUpdateLocationController:)]) {
		[delegate locationControllerDidUpdateLocationController: self];
	} 
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"new bssids");
	
	[self updateHoccability];
}


@end
