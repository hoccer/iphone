//
//  HoccerDownloadRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHoccerRequest.h"

@class HocLocation;


@interface HoccerDownloadRequest : NSObject {
	BaseHoccerRequest *request;
	id delegate;
}

@property (nonatomic, assign) id delegate;

- (id)initWithLocation: (HocLocation *)location gesture: (NSString *)gesture delegate: (id) aDelegate;
- (void)cancel;


@end
