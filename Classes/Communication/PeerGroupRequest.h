//
//  PeerGroupRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PeerGroupRequest : NSObject {
	NSURLConnection *connection;
	NSMutableData *receivedData;
}

- (id)initWithLocation: (CLLocation *)location andGesture: (NSString *)gesture;




@end
