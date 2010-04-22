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

@class HocLocation;

@interface PeerGroupRequest : BaseHoccerRequest {
	BOOL hasReceivedURL;
}

- (id)initWithLocation: (HocLocation *)location gesture: (NSString *)gesture delegate: (id)aDelegate;

@end
