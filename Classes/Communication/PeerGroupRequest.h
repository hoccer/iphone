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
	
	id delegate;
	
	id result;
}

@property (assign, nonatomic) id delegate;
@property (retain) id result;

- (id)initWithLocation: (CLLocation *)location gesture: (NSString *)gesture andDelegate: (id) aDelegate;




@end
