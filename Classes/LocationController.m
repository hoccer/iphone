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

#define hoccerMessageErrorDomain @"HoccerErrorDomain"

@interface LocationController ()
@property (assign) CLLocation *currentLocation;
- (void)updateHoccability;
- (NSDictionary *)userInfoForImpreciseLocation;
@end



@implementation LocationController

@synthesize lastLocationUpdate;
@synthesize hoccability;
@synthesize delegate;
@synthesize currentLocation;

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
	
	[super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation {
	self.currentLocation = newLocation;
	[self updateHoccability];
	
	if ([[NSDate date] timeIntervalSinceDate: lastLocationUpdate] < 10)
		return;
	
	geocoder = [[MKReverseGeocoder alloc] initWithCoordinate: newLocation.coordinate];
	geocoder.delegate = self;
	
	[geocoder start];
	
	self.lastLocationUpdate = [NSDate date];
	[self updateHoccability];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)aGeocoder didFindPlacemark: (MKPlacemark *)placemark {
	[geocoder release];
	geocoder = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError: (NSError *)error {
}

- (HocLocation *)location {
	return [[[HocLocation alloc] 
			 initWithLocation: currentLocation bssids:[WifiScanner sharedScanner].bssids] autorelease];
}

- (BOOL)hasLocation {
	return (locationManager.location.horizontalAccuracy != 0);
}

- (BOOL)hasBSSID {
	return [[WifiScanner sharedScanner].bssids count] != 0;
}

- (void)updateHoccability {
	self.hoccability = 0;
	
	if ([self hasLocation]) {
		if (locationManager.location.horizontalAccuracy < 200) {
			self.hoccability = 2;
		} else if (locationManager.location.horizontalAccuracy < 500) {
			self.hoccability = 1;
		}
	}

	if ([self hasBSSID]) {
		self.hoccability += 1;
	}
	
	if ([delegate respondsToSelector:@selector(locationControllerDidUpdateLocationController:)]) {
		[delegate locationControllerDidUpdateLocation: self];
	} 
}

- (NSError *)messageForLocationInformation {
	if (self.location.location.horizontalAccuracy < 200) {
		return nil;
	}
	
	return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageImpreciseLocation userInfo:[self userInfoForImpreciseLocation]];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {	
	[self updateHoccability];
}

#pragma mark -
#pragma mark private userInfo Methods
- (NSDictionary *)userInfoForImpreciseLocation {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Your location is bad!" forKey:NSLocalizedDescriptionKey];
	
	return [userInfo autorelease];
}

@end
