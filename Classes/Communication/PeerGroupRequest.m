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
#import "HocLocation.h"

const NSString *kHoccerServer = @"http://www.hoccer.com/";

@interface PeerGroupRequest (private) 
- (NSData *)bodyWithLocation: (HocLocation *)location gesture: (NSString *)gesture seeder: (BOOL) seeder;
@end

@implementation PeerGroupRequest

// @synthesize result;

- (id)initWithLocation: (HocLocation *)location gesture: (NSString *)gesture isSeeder: (BOOL)seeder delegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		
		NSString *urlString = [NSString stringWithFormat:@"%@%@", kHoccerServer, @"peers"];
		NSURL *url = [NSURL URLWithString: urlString];
			
		[self.request setURL: url];
		[self.request setHTTPMethod: @"POST"];
		[self.request setHTTPBody: [self bodyWithLocation: location gesture: gesture seeder: seeder]];	
			
		self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self]; 
		if (!connection)  {
			NSLog(@"Error while executing url connection");
		}
		
		[self.delegate checkAndPerformSelector: @selector(request:didPublishUpdate:) withObject: self withObject: @"Connecting..."];
	}
	
	return self;	
}

- (NSData *)bodyWithLocation: (HocLocation *)hocLocation gesture: (NSString *)gesture seeder: (BOOL) seeder
{
	
	CLLocation *location = hocLocation.location;
	
	NSMutableString *body = [NSMutableString string];
	[body appendFormat:@"peer[latitude]=%f&", location.coordinate.latitude];
	[body appendFormat:@"peer[longitude]=%f&", location.coordinate.longitude];
	[body appendFormat:@"peer[accuracy]=%f&", location.horizontalAccuracy];
	[body appendFormat:@"peer[gesture]=%@&", gesture];
	[body appendFormat:@"peer[seeder]=%d", seeder];
	
	if (hocLocation.bssids != nil) {
		NSString *ids = [hocLocation.bssids componentsJoinedByString:@","];
		
		[body appendFormat:@"&peer[bssids]=%@", ids];
	}

	NSLog(@"request body: %@", body);
	return [body dataUsingEncoding: NSUTF8StringEncoding];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection 
{
	
	self.result = [self createJSONFromResult: receivedData];
	self.connection = nil;
	
	[delegate checkAndPerformSelector:@selector(finishedRequest:) withObject: self];
}


@end
