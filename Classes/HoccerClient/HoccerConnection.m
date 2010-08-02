//
//  HoccerRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerConnection.h"
#import "PeerGroupRequest.h"
#import "DeleteRequest.h"
#import "HoccerClient.h"
#import "NSObject+DelegateHelper.h"

#define hoccerMessageErrorDomain @"HoccerErrorDomain"


@interface HoccerConnection ()
- (NSDictionary *)userInfoForNoCatcher;
- (NSDictionary *)userInfoForNoThrower;
- (NSDictionary *)userInfoForNoSecondSweeper;
- (NSDictionary *)userInfoForInterception;
- (NSError *)createAppropriateError;
- (NSError *)createAppropriateCollisionError;
@end


@implementation HoccerConnection
@synthesize delegate;
@synthesize gesture;
@synthesize status;

@synthesize responseBody;
@synthesize responseHeader;
@synthesize location;

@synthesize eventURL;

- (void)cancel {
	if (eventURL == nil) {
		eventURL = [request.eventUri retain];
	}
	
	deleteRequest = [[DeleteRequest alloc] initWithPeerGroupUri: request.eventUri];
}

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error {
	[request release];
	request = nil;
	
	NSDictionary *errorResponse = [[error userInfo] objectForKey:@"HoccerErrorDescription"];
	NSLog(@"errorResponse :%@", errorResponse);
	
	if ([error code] == 410 || ( [[errorResponse objectForKey:@"state"] isEqual:@"no_seeders"] ||
								[[errorResponse objectForKey:@"state"] isEqual:@"no_peers"] ) )  {
		
		error = [self createAppropriateError];
	} else if ([error code] == 409) {
		error = [self createAppropriateCollisionError];
	}
	
	[self cancel];
	[self.delegate checkAndPerformSelector: @selector(hoccerConnection:didFailWithError:) withObject: self 
								withObject: error];
}

// abstract
- (void)startConnection {
	[self doesNotRecognizeSelector:_cmd];
}

- (void) dealloc {
	[gesture release];
	[request release];
	[location release];
	[status release];
	[eventURL release];
	
	[responseBody release];
	[responseHeader release];
	[super dealloc];
}

#pragma mark -
#pragma mark Private UserInfo Methods 

- (NSError *)createAppropriateError {
	if ([gesture isEqual:@"Throw"]) {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoCatcher userInfo:[self userInfoForNoCatcher]];
	}
	
	if ([gesture isEqual:@"Catch"]) {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoThrower userInfo:[self userInfoForNoThrower]];
	}
	
	return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoSecondSweeper userInfo:[self userInfoForNoSecondSweeper]];
}

- (NSError *)createAppropriateCollisionError {
	return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageCollision userInfo:[self userInfoForInterception]];
}


- (NSDictionary *)userInfoForNoCatcher {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:NSLocalizedString(@"Nobody caught your content!", nil) forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:NSLocalizedString(@"Timing is important. The other person needs to catch just after you have thrown.", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
}

- (NSDictionary *)userInfoForNoThrower {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:NSLocalizedString(@"Nothing was thrown to you!", nil) forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:NSLocalizedString(@"Timing is important. You need to catch right after the other person has thrown.", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
	
}

- (NSDictionary *)userInfoForNoSecondSweeper {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:NSLocalizedString(@"No second device found!", nil) forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:NSLocalizedString(@"Asure that you really sweept over the edges of both devices.", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
}

- (NSDictionary *)userInfoForInterception {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:NSLocalizedString(@"Your hoc has been intercepted", nil) forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:NSLocalizedString(@"Only the right person should get you content. Unfortunatly someone else tried to hoc at your location. Try it again in a moment.", nil) forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
}

@end
