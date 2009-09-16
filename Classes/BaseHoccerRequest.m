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

@synthesize delegate;
@synthesize response;
@synthesize result;
@synthesize connection;

- (id)init
{
	self = [super init];
	if (self != nil) {
		receivedData = [[NSMutableData alloc] init]; 
		
		canceled = NO;
	}
	return self;
}

- (void)cancel 
{
	NSLog(@"canceling connection: %@", connection);
	[self.connection cancel];
	self.connection = nil;
	
	canceled = YES;
}


- (void)dealloc 
{
	[super dealloc];
	[receivedData release];
	
	// TODO: check why releaseing connection crashes?
	//NSLog(@"connection: %@", connection);
	//[connection release];
	[response release]; 
	[result release];
	
}

#pragma mark private helper methods

- (id) createJSONFromResult: (NSData *) resultData 
{
	NSError *error;

	NSString *dataString = [[NSString alloc] initWithData: resultData encoding: NSUTF8StringEncoding];
	NSLog(@"received: %@", dataString);
	SBJSON *json = [[SBJSON alloc] init];
	id jsonResult = [json objectWithString: dataString error: &error];
	[json release];
	[dataString release];
	
	return jsonResult;
}

- (NSError *)createErrorFromResult: (id)aResult {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	if ([aResult valueForKey:@"message"]) {
		[userInfo setObject:[aResult valueForKey:@"message"] forKey:NSLocalizedDescriptionKey];
	}
	
	NSInteger statusCode = [self.response statusCode];
	NSError *error = [NSError errorWithDomain:@"HoccerCommunicationError" code:statusCode userInfo:userInfo];
	
	return error;
}

#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}


- (void)connection:(NSURLConnection *)aConnection didFailWithError: (NSError *)error 
{
	self.connection = nil;
	
	[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)aResponse 
{
	self.response = aResponse;
	NSLog(@"status code: %d", [response statusCode]);
	NSLog(@"response length: %d", [response expectedContentLength]);
}



@end
