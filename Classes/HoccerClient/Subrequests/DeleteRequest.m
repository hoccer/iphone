//
//  DeleteRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 07.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DeleteRequest.h"
#import "NSObject+DelegateHelper.h"


@implementation DeleteRequest

- (id)initWithPeerGroupUri: (NSURL *)peerGroupUri {
	self = [super init];
	if (self != nil) {		
		NSMutableURLRequest *deleateRequest = [NSMutableURLRequest requestWithURL:peerGroupUri];
		[deleateRequest setHTTPMethod:@"DELETE"];
		[deleateRequest addValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

		self.connection  = [[NSURLConnection alloc] initWithRequest:deleateRequest delegate:self];
	
		if (!self.connection)  {
		 	NSLog(@"Error while executing url connection");
		}
	}
	
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	self.connection = nil;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError: (NSError *)error {
	self.connection = nil;
	
	[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: error];
}

@end
