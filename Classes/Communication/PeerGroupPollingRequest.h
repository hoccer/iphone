//
//  PeerGroupPollingRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PeerGroupPollingRequest : NSObject {
	id delegate;
	NSURLRequest *request;
	NSURLConnection *connection;
	
	NSHTTPURLResponse *response; 
	
	NSMutableData *receivedData;
}

@property (assign, nonatomic) id delegate;
@property (retain) NSHTTPURLResponse *response;

- (id)initWithObject: (id)aObject andDelegate: (id)delegate;

@end
