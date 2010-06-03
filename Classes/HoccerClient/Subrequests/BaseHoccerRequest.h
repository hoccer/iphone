	//
//  BaseHoccerRequest.h
//  Hoccer
//
//  Created by Robert Palmer on 08.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseHoccerRequest;

@protocol BaseHoccerRequestDelegate
@optional
- (void)request:(BaseHoccerRequest *)request didFailWithError: (NSError *)error;
- (void)requestDidFinish: (BaseHoccerRequest *)request;
@end



@interface BaseHoccerRequest : NSObject {
	NSString *userAgent;
	id delegate;

	NSURLRequest *request;
	NSMutableData *receivedData;

	NSURLConnection *connection;
	NSHTTPURLResponse *response; 
	id result;
	
	BOOL canceled;
}

@property (assign, nonatomic) id delegate;
@property (copy) NSString* userAgent;
@property (retain) NSURLRequest *request;
@property (retain) NSHTTPURLResponse *response;
@property (retain) NSURLConnection *connection;
@property (retain) id result;

- (id) parseJsonToDictionary: (NSData *) resultData;
- (NSError *) parseJsonToError: (id)aResult;

- (void)cancel;

@end
