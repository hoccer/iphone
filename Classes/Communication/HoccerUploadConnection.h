//
//  HoccerUploadContent.h
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"
#import "HoccerConnection.h"

@class BaseHoccerRequest;
@class HocLocation;


@interface HoccerUploadConnection : HoccerConnection {
	BaseHoccerRequest *upload;
	
	HoccerContent* content;
	NSString *type;
	NSString *filename;
	
	BOOL uploadDidFinish, pollingDidFinish;
	BOOL isCanceled;
	
	NSURL *uploadUrl;
	NSTimer *timer;
	
	NSDictionary *status;
}

@property (retain) HoccerContent* content;
@property (retain) NSString *type;
@property (retain) NSString *filename;

- (id)initWithLocation: (HocLocation *)location gesture: (NSString *)gesture content: (HoccerContent *)theContent 
				  type: (NSString *)aType filename: (NSString *)aFilename delegate: (id)aDelegate;
- (void)cancel;

@end
