//
//  UploadRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHoccerRequest.h"


@interface UploadRequest : BaseHoccerRequest {
	NSMutableURLRequest *request;
}

- (id)initWithResult: (id) aResult data: (NSData *)bodyData type: (NSString *)type filename: (NSString *)filename delegate: (id)aDelegate;
@end
