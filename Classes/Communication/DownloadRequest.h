//
//  DownloadRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 08.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHoccerRequest.h"

@interface DownloadRequest : BaseHoccerRequest {
	NSURLRequest *request;
	NSURLConnection *connection;
}

@property (retain) NSURLConnection *connection;
@property (retain) NSURLRequest *request;

- (id)initWithObject: (id)aObject delegate: (id)aDelegate;

@end
