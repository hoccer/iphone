//
//  LocationController.h
//  Hoccer
//
//  Created by Robert Palmer on 16.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerViewController.h"

@class HocLocation;

@interface LocationController : NSObject <MKReverseGeocoderDelegate, CLLocationManagerDelegate> {
	HoccerViewController *viewController;
	
	CLLocationManager *locationManager;
	NSDate *lastLocationUpdate;
	MKReverseGeocoder *geocoder;
	NSInteger hoccability;
	
	id <LocationControllerDelegate> delegate;
}

@property (retain) IBOutlet HoccerViewController *viewController;
@property (retain) NSDate *lastLocationUpdate;
@property (readonly) HocLocation *location;
@property (assign) NSInteger hoccability;
@property (assign) id <LocationControllerDelegate> delegate;

- (BOOL)hasLocation;
- (BOOL)hasBSSID;

@end
