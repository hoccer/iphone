//
//  HocLocation.h
//  Hoccer
//
//  Created by Robert Palmer on 27.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface HocLocation : NSObject {
	NSArray *bssids;
	CLLocation *location;
}

@property (retain) NSArray *bssids;
@property (retain) CLLocation *location;

- (id) initWithLocation: (CLLocation *)theLocation bssids: (NSArray*) theBssids;

@end