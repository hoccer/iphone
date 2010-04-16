//
//  LocationController.h
//  Hoccer
//
//  Created by Robert Palmer on 16.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerViewController.h"

#define kHoccerMessageImpreciseLocation 1
#define kHoccerBadLocation 2

@class HocLocation;

@interface LocationController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	NSDate *lastLocationUpdate;
	NSInteger hoccability;
	id <LocationControllerDelegate> delegate;

	@private 
	CLLocation *currentLocation;
	NSInteger oldHoccability;
}

@property (retain) NSDate *lastLocationUpdate;
@property (readonly) HocLocation *location;
@property (assign) NSInteger hoccability;
@property (assign) id <LocationControllerDelegate> delegate;

- (BOOL)hasLocation;
- (BOOL)hasBSSID;
- (NSError *)messageForLocationInformation;


@end
