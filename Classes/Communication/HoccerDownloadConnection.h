//
//  HoccerDownloadRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHoccerRequest.h"
#import "HoccerConnection.h"

@class HocLocation;
@class DownloadRequest;

@interface HoccerDownloadConnection : HoccerConnection {
	DownloadRequest *downloadRequest;
}

@property (retain) NSDictionary *status;

- (id)initWithLocation: (HocLocation *)location gesture: (NSString *)gesture delegate: (id) aDelegate;
- (void)cancel;


@end
