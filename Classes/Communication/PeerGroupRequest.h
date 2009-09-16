//
//  PeerGroupRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BaseHoccerRequest.h"

@interface PeerGroupRequest : BaseHoccerRequest {
}

- (id)initWithLocation: (CLLocation *)location gesture: (NSString *)gesture isSeeder: (BOOL)seeder delegate: (id)aDelegate;

@end
