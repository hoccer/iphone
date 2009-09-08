//
//  PeerGroupPollingRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHoccerRequest.h"

@interface PeerGroupPollingRequest : BaseHoccerRequest {
	id delegate;
	
	NSURLRequest *request;
	NSURLConnection *connection;
}

@property (assign, nonatomic) id delegate;
@property (retain) NSHTTPURLResponse *response;
@property (retain) NSURLConnection *connection;


- (id)initWithObject: (id)aObject andDelegate: (id)delegate;

@end
