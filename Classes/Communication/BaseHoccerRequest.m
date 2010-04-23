//
//  BaseHoccerRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 08.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "BaseHoccerRequest.h"
#import "NSObject+DelegateHelper.h"
#import "JSON.h"


@implementation BaseHoccerRequest

@synthesize userAgent;
@synthesize delegate;
@synthesize response;
@synthesize result;
@synthesize connection;
@synthesize request;

- (id)init {
	self = [super init];
	if (self != nil) {
		receivedData = [[NSMutableData alloc] init]; 
		
		NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey: @"CFBundleVersion"];
		self.userAgent = [NSString stringWithFormat: @"Hoccer /%@ iPhone", version];
		
		canceled = NO;
	}
	return self;
}

- (void)cancel {
	[self.connection cancel];
	self.connection = nil;
	
	canceled = YES;
}


- (void)dealloc {
	[receivedData release];
	
	[connection release];
	[response release]; 
	[result release];
	
	[request release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark private helper methods

- (id)parseJsonToDictionary: (NSData *) resultData {
	NSError *error;

	NSString *dataString = [[NSString alloc] initWithData: resultData encoding: NSUTF8StringEncoding];
	SBJSON *json = [[SBJSON alloc] init];
	id jsonResult = [json objectWithString: dataString error: &error];
	[json release];
	[dataString release];
	
	return jsonResult;
}

- (NSError *)parseJsonToError: (id)aResult {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	if ([aResult valueForKey:@"message"]) {
		[userInfo setObject:[aResult valueForKey:@"message"] forKey:NSLocalizedDescriptionKey];
		[userInfo setObject:aResult forKey:@"HoccerErrorDescription"];
	}
	
	NSInteger statusCode = [self.response statusCode];
	NSError *error = [NSError errorWithDomain:@"HoccerCommunicationError" code:statusCode userInfo:userInfo];
	
	return error;
}

#pragma mark -
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError: (NSError *)error {
	self.connection = nil;
	
	[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)aResponse {
	self.response = aResponse;
}



@end
