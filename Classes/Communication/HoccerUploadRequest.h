//
//  HoccerUploadContent.h
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"
#import "HoccerRequest.h"

@class BaseHoccerRequest;
@class HocLocation;


@interface HoccerUploadRequest : HoccerRequest {
	BaseHoccerRequest *request;
	BaseHoccerRequest *upload;
	
	id <HoccerContent> content;
	NSString *type;
	NSString *filename;
	
	id delegate;
	
	BOOL uploadDidFinish, pollingDidFinish;
	BOOL isCanceled;
	
	NSTimer *timer;
}

@property (nonatomic, assign) id delegate;
@property (retain) id <HoccerContent> content;
@property (retain) NSString *type;
@property (retain) NSString *filename;

- (id)initWithLocation: (HocLocation *)location gesture: (NSString *)gesture content: (id <HoccerContent>)theContent 
				  type: (NSString *)aType filename: (NSString *)aFilename delegate: (id)aDelegate;
- (void)cancel;

@end
