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
	NSString *type;
	NSString *filename;
	
	id delegate;
	
	BOOL uploadDidFinish, pollingDidFinish;
}

@property (nonatomic, assign) id delegate;
@property (retain) NSData *data;
@property (retain) NSString *type;
@property (retain) NSString *filename;

- (id)initWithLocation: (CLLocation *)location gesture: (NSString *)gesture data: (NSData *)aData 
				  type: (NSString *)aType filename: (NSString *)aFilename delegate: (id)aDelegate;
- (void)cancel;

@end
