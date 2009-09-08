//
//  BaseHoccerRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 08.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "BaseHoccerRequest.h"


@implementation BaseHoccerRequest

@synthesize delegate;
@synthesize response;
@synthesize result;

- (id)init
{
	self = [super init];
	if (self != nil) {
		receivedData = [[NSMutableData alloc] init]; 
	}
	return self;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)aResponse 
{
	self.response = aResponse;
	NSLog(@"status code: %d", [response statusCode]);
	NSLog(@"response length: %d", [response expectedContentLength]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

- (void)dealloc 
{
	[super dealloc];
	[receivedData release];
}


@end
