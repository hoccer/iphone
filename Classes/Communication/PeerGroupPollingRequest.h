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
	NSURLRequest *request;
}

- (id)initWithObject: (id)aObject andDelegate: (id)delegate;

@end
