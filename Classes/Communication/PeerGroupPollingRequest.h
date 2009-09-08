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
}

@property (assign, nonatomic) id delegate;

- (void)initWithObject: (id)aObject andDelegate: (id)delegate;

@end
