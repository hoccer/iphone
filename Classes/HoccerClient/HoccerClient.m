//
//  HoccerClient.m
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerClient.h"
#import "HoccerUploadConnection.h"
#import "HoccerDownloadConnection.h"
#import "BaseHoccerRequest.h"

#import "HocLocation.h"
#import "HoccerContent.h"
#import "HoccerRequest.h"

#import "NSObject+DelegateHelper.h"

@implementation HoccerClient

@synthesize content;
@synthesize userAgent;
@synthesize delegate;

- (HoccerConnection *)connectionWithRequest: (HoccerRequest *)aRequest {
	HoccerConnection *connection = [self unstartedConnectionWithRequest:aRequest];
	[connection startConnection];
	
	return connection;
}

- (HoccerConnection *)unstartedConnectionWithRequest:(HoccerRequest *)aRequest {
	if ([aRequest.gesture isEqual:@"SweepOut"] || [aRequest.gesture isEqual:@"Throw"]) {
		return [[[HoccerUploadConnection alloc] initWithLocation:aRequest.location gesture:aRequest.gesture content: aRequest.content type:[aRequest.content mimeType] 
														filename:[aRequest.content filename] delegate:self.delegate] autorelease];
	} else {
		return [[[HoccerDownloadConnection alloc] initWithLocation:aRequest.location gesture:aRequest.gesture delegate:self.delegate] autorelease];
	}
	
	@throw [NSException exceptionWithName:@"HoccerException" reason:[NSString stringWithFormat:@"The gesture %@ is unknown", aRequest.gesture] userInfo:nil];
}	

- (void) dealloc {
	[userAgent release];
	[content release];

	[super dealloc];
}



@end
