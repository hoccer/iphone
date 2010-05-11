//
//  DeleteRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 07.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHoccerRequest.h"


@interface DeleteRequest : BaseHoccerRequest {

}

- (id)initWithPeerGroupUri: (NSURL *)peerGroupUri;



@end