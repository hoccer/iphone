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
@property (retain) CLLocation *currentLocation;
- (void)updateHoccability;
- (NSDictionary *)userInfoForImpreciseLocation;
- (NSDictionary *)userInfoForBadLocation;

- (NSString *)impoveSuggestion;
@end



@implementation LocationController

@synthesize lastLocationUpdate;
@synthesize hoccability;
@synthesize delegate;
@synthesize currentLocation;
@synthesize bssids;

- (id) init {
	self = [super init];
	if (self != nil) {
		oldHoccability = -1;
		
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
	[lastLocationUpdate release];
	[locationManager stopUpdatingLocation];
	[locationManager release];
	[bssids release];
	
	[super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation {
	self.currentLocation = newLocation;
	[self updateHoccability];
	
	if ([[NSDate date] timeIntervalSinceDate: lastLocationUpdate] < 10)
		return;
	
	self.lastLocationUpdate = [NSDate date];
	[self updateHoccability];
}

- (HocLocation *)location {
	return [[[HocLocation alloc] 
			 initWithLocation: currentLocation bssids:[WifiScanner sharedScanner].bssids] autorelease];
}

- (BOOL)hasLocation {
	return (currentLocation.horizontalAccuracy != 0);
}

- (BOOL)hasBadLocation {
	return (![self hasLocation] || self.location.location.horizontalAccuracy > 200);
}

- (BOOL)hasBSSID {
	return self.bssids != nil;
}

- (void)updateHoccability {
	self.hoccability = 0;
	
	if ([self hasLocation]) {
		if (locationManager.location.horizontalAccuracy < 200) {
			self.hoccability = 2;
		} else if (locationManager.location.horizontalAccuracy < 2000) {
			self.hoccability = 1;
		}
	}

	if ([self hasBSSID]) {
		self.hoccability += 1;
	}
	
	if (hoccability != oldHoccability) {
		if ([delegate respondsToSelector:@selector(locationControllerDidUpdateLocation:)]) {
			[delegate locationControllerDidUpdateLocation: self];
			oldHoccability = hoccability;
		} 
	}

}

- (NSError *)messageForLocationInformation {
	NSLog(@"accuracy: %f, %d", self.location.location.horizontalAccuracy, [self hasLocation]);
	if (![self hasLocation] ||  self.location.location.horizontalAccuracy > 2000) {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerBadLocation userInfo:[self userInfoForBadLocation]];
	}
	
	if (self.location.location.horizontalAccuracy > 200) {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerImpreciseLocation userInfo:[self userInfoForImpreciseLocation]];
	}
	
	return nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {	
	self.bssids = [WifiScanner sharedScanner].bssids;
	[self updateHoccability];
}

#pragma mark -
#pragma mark private userInfo Methods
- (NSDictionary *)userInfoForImpreciseLocation {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Your location accuracy is imprecise!" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:[self impoveSuggestion] forKey:NSLocalizedRecoverySuggestionErrorKey];

	return [userInfo autorelease];
}

- (NSDictionary *)userInfoForBadLocation {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Your location accuracy is to imprecise for hoccing" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:[self impoveSuggestion] forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
}

- (NSString *)impoveSuggestion {
	NSMutableArray *suggestions = [[NSMutableArray alloc] initWithCapacity:2];
	NSMutableString *suggestion = [[NSMutableString alloc] init];
	
	if (![self hasBSSID]) {
		[suggestions addObject:@"turning on the phones wifi"];
	}
	
	if ([self hasBadLocation]) {
		[suggestions addObject:@"going outside"];
	}
	
	[suggestion appendString:@"Hoccer needs to locate you precisely to find your exchange partner. You can improve your location by "];
	[suggestion appendString:[suggestions componentsJoinedByString:@" or "]];

	return [suggestion autorelease];
}


@end
