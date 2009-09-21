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
- (NSData *)bodyWithLocation: (CLLocation *)location gesture: (NSString *)gesture seeder: (BOOL) seeder;
@end

@implementation PeerGroupRequest

@synthesize result;

- (id)initWithLocation: (CLLocation *)location gesture: (NSString *)gesture isSeeder: (BOOL)seeder delegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		
		NSString *urlString = [NSString stringWithFormat:@"%@%@", kHoccerServer, @"peers"];
		NSLog(@"sending request to: %@", urlString);
		NSURL *url = [NSURL URLWithString: urlString];
			
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		[request setHTTPMethod: @"POST"];
		[request setHTTPBody: [self bodyWithLocation: location gesture: gesture seeder: seeder]];	
			
		self.connection = [NSURLConnection connectionWithRequest:request delegate:self]; 
		if (!connection)  {
			NSLog(@"Error while executing url connection");
		}
		
		[self.delegate checkAndPerformSelector: @selector(request:didPublishUpdate:) withObject: self withObject: @"Connecting..."];
	}
	
	return self;	
}

- (NSData *)bodyWithLocation: (CLLocation *)location gesture: (NSString *)gesture seeder: (BOOL) seeder
{
	NSMutableString *body = [NSMutableString string];
	[body appendFormat:@"peer[latitude]=%f&", location.coordinate.latitude];
	[body appendFormat:@"peer[longitude]=%f&", location.coordinate.longitude];
	[body appendFormat:@"peer[accuracy]=%i&", location.horizontalAccuracy];
	[body appendFormat:@"peer[gesture]=%@&", gesture];
	[body appendFormat:@"peer[seeder]=%d", seeder];

	NSLog(@"body: %@", body);
	return [body dataUsingEncoding: NSUTF8StringEncoding];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection 
{
	NSLog(@"connection did finish");
	
	self.result = [self createJSONFromResult: receivedData];
	self.connection = nil;
	
	[delegate checkAndPerformSelector:@selector(finishedRequest:) withObject: self];
}


@end
