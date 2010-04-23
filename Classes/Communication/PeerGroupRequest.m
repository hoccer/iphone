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

const NSString *kHoccerServer = @"http://beta.hoccer.com/";

@interface PeerGroupRequest (private) 
- (NSData *)bodyWithLocation: (HocLocation *)location gesture: (NSString *)gesture;
- (void)startRequest;
@end

@implementation PeerGroupRequest

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
		[self.delegate checkAndPerformSelector: @selector(request:didPublishUpdate:) withObject: self withObject: @"Connecting..."];
	}
	
	return self;	
}

- (void)startRequest {
	if (canceled) { return; }
	
	self.connection = [[[NSURLConnection alloc] initWithRequest: self.request delegate:self] autorelease];
	if (!self.connection)  {
		NSLog(@"Error while executing url connection");
	}
	
	[receivedData setLength:0];
}


#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	self.result = [self parseJsonToDictionary: receivedData];
	
	[delegate checkAndPerformSelector:@selector(peerGroupRequest:didReceiveUpdate:) withObject: self withObject: self.result];
	if ([[self.result objectForKey:@"state"] isEqual:@"waiting"]) {
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRequest) userInfo:nil repeats:NO];
		return;
	}
	
	if ([self.response statusCode] >= 400) {
		NSError *error = [self parseJsonToError: self.result];
		[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: error];
	} else {
		[self.delegate checkAndPerformSelector:@selector(peerGroupRequestDidFinish:) withObject: self];
	}

	self.connection = nil;
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
	[body appendFormat:@"event[latitude]=%f&", location.coordinate.latitude];
	[body appendFormat:@"event[longitude]=%f&", location.coordinate.longitude];
	[body appendFormat:@"event[location_accuracy]=%f&", location.horizontalAccuracy];
	[body appendFormat:@"event[type]=%@", gesture];
	
	if (hocLocation.bssids != nil) {
		NSString *ids = [hocLocation.bssids componentsJoinedByString:@","];
		[body appendFormat:@"&event[bssids]=%@", ids];
	}
	
	
	NSLog(@"body: %@", body);
	return [body dataUsingEncoding: NSUTF8StringEncoding];
}



@end
