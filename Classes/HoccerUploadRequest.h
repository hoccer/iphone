//
//  HoccerUploadContent.h
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseHoccerRequest;

@interface HoccerUploadRequest : NSObject {
	BaseHoccerRequest *request;
	BaseHoccerRequest *upload;
	
	NSData *data;
	
	id delegate;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSData *data;

- (id) initWithLocation: (CLLocation *)location gesture: (NSString *)gesture data: (NSData *)aData delegate: (id)aDelegate;
- (void)cancel;

@end
