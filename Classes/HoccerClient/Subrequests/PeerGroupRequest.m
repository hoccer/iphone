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
#import "WifiScanner.h"
#import "HocLocation.h"


const NSString *kHoccerServer = @"http://beta.hoccer.com/";

@interface PeerGroupRequest () 
@property (retain) NSDate *requestStartTime;

- (NSData *)bodyWithLocation: (HocLocation *)location gesture: (NSString *)gesture;
- (void)startRequest;
@end

@implementation PeerGroupRequest
@synthesize requestStartTime;
@synthesize roundTripTime;

- (id)initWithLocation: (HocLocation *)location gesture: (NSString *)gesture delegate: (id)aDelegate {
	self = [super init];
	
	if (self != nil) {
		self.delegate = aDelegate;
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@%@", kHoccerServer, @"events"]];
		
		NSMutableURLRequest *eventRequest = [NSMutableURLRequest requestWithURL:url];
		[eventRequest setHTTPMethod: @"POST"];
		[eventRequest setHTTPBody: [self bodyWithLocation: location gesture: gesture]];	
		[eventRequest setValue: self.userAgent forHTTPHeaderField:@"User-Agent"];
		self.request = eventRequest;
			
		[self startRequest];		
	}
	return self;	
}

- (NSURL *)eventUri {
	return [self.request URL];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	self.result = [self parseJsonToDictionary: receivedData];
	
	if (self.response == nil) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"A problem occurred on the server. Try again in a moment." forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain: @"HoccerErrorDomain" code:1 userInfo:userInfo];

		[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: error];
		return;
	}
		
	if ([self.response statusCode] >= 400) {
		NSError *error = [self parseJsonToError: self.result];
		[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: error];
		return;
	}
	
	if (!canceled) {
		[delegate checkAndPerformSelector:@selector(peerGroupRequest:didReceiveUpdate:) withObject: self withObject: self.result];
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRequest) userInfo:nil repeats:NO];
	}
	
	self.connection = nil;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSHTTPURLResponse *)aResponse {
	[super connection:connection didReceiveResponse:aResponse];
	
	self.roundTripTime = [[NSDate date] timeIntervalSinceDate: requestStartTime];
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)theRequest redirectResponse:(NSURLResponse *)redirectResponse {
	self.request = theRequest;
    return theRequest;
}

#pragma mark -
#pragma mark Private Methods

- (NSData *)bodyWithLocation: (HocLocation *)hocLocation gesture: (NSString *)gesture {
	CLLocation *location = hocLocation.location;
	
	NSMutableString *body = [NSMutableString string];
	
	if (location != nil) {
		[body appendFormat:@"event[latitude]=%f&", location.coordinate.latitude];
		[body appendFormat:@"event[longitude]=%f&", location.coordinate.longitude];
		[body appendFormat:@"event[location_accuracy]=%f&", location.horizontalAccuracy];		
	}
	
	if (hocLocation.bssids != nil) {
		NSString *ids = [hocLocation.bssids componentsJoinedByString:@","];
		[body appendFormat:@"event[bssids]=%@&", ids];
	}
	
	[body appendFormat:@"event[hoccability]=%d&", hocLocation.hoccability]; 
	[body appendFormat:@"event[type]=%@&", gesture];
	
	
	[body appendFormat:@"event[local_ip]=%@&", [[[WifiScanner sharedScanner] localIpAddress] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[body appendFormat:@"event[model]=%@&", [[UIDevice currentDevice].model stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[body appendFormat:@"event[device]=%@&", [[UIDevice currentDevice].systemName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[body appendFormat:@"event[version_sdk]=%@&", [[UIDevice currentDevice].systemVersion stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[body appendFormat:@"event[timestamp]=%0.0f&", [[NSDate date] timeIntervalSince1970] * 1000];
	[body appendFormat:@"event[client_uuid]=%@", [[UIDevice currentDevice].uniqueIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	return [body dataUsingEncoding: NSUTF8StringEncoding];
}

- (void)startRequest {
	if (canceled) { 
		return; 
	}
	NSLog(@"request uri: %@", [self.request URL]);
	self.requestStartTime = [NSDate date];
	
	NSMutableURLRequest *requestWithRtt = [self.request mutableCopy];
	[requestWithRtt addValue:[[NSNumber numberWithInt:self.roundTripTime * 1000] stringValue] forHTTPHeaderField:@"X-Rtt"];
	[requestWithRtt addValue:[UIDevice currentDevice].uniqueIdentifier forHTTPHeaderField:@"X-Client-Uuid"];
	
	self.connection = [[[NSURLConnection alloc] initWithRequest: requestWithRtt delegate:self] autorelease];
	[requestWithRtt release];

	if (!self.connection)  {
		NSLog(@"Error while executing url connection");
	}
	
	[receivedData setLength:0];
}

@end
