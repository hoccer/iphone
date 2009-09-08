//
//  PeerGroupRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PeerGroupRequest.h"
#import "JSON.h"
#import "NSObject+DelegateHelper.h"

const NSString *kHoccerServer = @"http://www.hoccer.com/";

@interface PeerGroupRequest (private) 
- (NSData *)bodyWithLocation: (CLLocation *)location andGesture: (NSString *)gesture;
@end

@implementation PeerGroupRequest

@synthesize result;

- (id)initWithLocation: (CLLocation *)location gesture: (NSString *)gesture andDelegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		
		NSString *urlString = [NSString stringWithFormat:@"%@%@", kHoccerServer, @"peers"];
		NSLog(@"sending request to: %@", urlString);
		NSURL *url = [NSURL URLWithString: urlString];
			
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		[request setHTTPMethod: @"POST"];
		[request setHTTPBody: [self bodyWithLocation: location andGesture: gesture]];	
			
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
		if (!connection)  {
			NSLog(@"Error while executing url connection");
		}
	}
	
	return self;	
}

- (NSData *)bodyWithLocation: (CLLocation *)location andGesture: (NSString *)gesture 
{
	NSMutableString *body = [NSMutableString string];
	[body appendFormat:@"peer[latitude]=%f&", location.coordinate.latitude];
	[body appendFormat:@"peer[longitude]=%f&", location.coordinate.longitude];
	[body appendFormat:@"peer[accuracy]=%i&", location.horizontalAccuracy];
	[body appendFormat:@"peer[gesture]=%@", gesture];

	return [body dataUsingEncoding: NSUTF8StringEncoding];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection 
{
	NSLog(@"connection did finish");
	NSError *error;
	
	NSString *dataString = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
	SBJSON *json = [[SBJSON alloc] init];
	self.result = [json objectWithString: dataString error: &error];
	[json release];
	
	[dataString release];
	[connection release];
	connection = nil;
	
	[delegate checkAndPerformSelector:@selector(finishedRequest:) withObject: self];
}


- (void)dealloc 
{
	[super dealloc];
	[connection release];
}



@end
