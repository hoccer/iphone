//
//  HoccerClient.m
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerClient.h"
#import "HoccerUploadRequest.h"
#import "HoccerDownloadRequest.h"
#import "BaseHoccerRequest.h"

#import "HocLocation.h"
#import "HoccerContent.h"

#import "NSObject+DelegateHelper.h"

#define hoccerMessageErrorDomain @"HoccerErrorDomain"

@interface HoccerClient ()
@property (copy) NSString *gesture;

- (NSString *)transferTypeFromGestureName: (NSString *)name;
- (NSDictionary *)userInfoForNoCatcher;
- (NSDictionary *)userInfoForNoThrower;
- (NSDictionary *)userInfoForNoSecondSweeper;
- (NSDictionary *)userInfoForInterception;
- (NSError *)createAppropriateError;
- (NSError *)createAppropriateCollisionError;

@end


@implementation HoccerClient

@synthesize gesture;
@synthesize hocLocation;
@synthesize content;
@synthesize userAgent;

@synthesize delegate;

- (void)uploadWithGesture: (NSString *)theGesture {
	self.gesture = theGesture;
	request = [[HoccerUploadRequest alloc] initWithLocation:hocLocation gesture:[self transferTypeFromGestureName:gesture] content:content type:@"plain/text" filename:@"unit_text.txt" delegate:self];
}

- (void)downloadWithGesture:(NSString *)theGesture {
	self.gesture = theGesture;
	request = [[HoccerDownloadRequest alloc] initWithLocation:hocLocation gesture:[self transferTypeFromGestureName:gesture] delegate:self];
}

- (void)requestDidFinishUpload: (HoccerUploadRequest *)theRequest {
	[delegate checkAndPerformSelector: @selector(hoccerClientDidFinishLoading:) withObject: self];	
}

- (void)request: (BaseHoccerRequest *)request didFailWithError: (NSError *)error {
	NSDictionary *errorResponse = [[error userInfo] objectForKey:@"HoccerErrorDescription"];
	NSLog(@"errorResponse :%@", errorResponse);
	
	if ([error code] == 500 || 
		( [[errorResponse objectForKey:@"state"] isEqual:@"no_seeders"] ||
		 [[errorResponse objectForKey:@"state"] isEqual:@"no_peers"] ) )  {
			
			error = [self createAppropriateError];
		} else if ([error code] == 409) {
			error = [self createAppropriateCollisionError];
		}
	
	NSLog(@"failed");
	[delegate checkAndPerformSelector: @selector(hoccerClient:didFailWithError:) withObject: self withObject: error];
}

- (void)requestDidFinishDownload: (HoccerDownloadRequest *)theRequest {
	[delegate checkAndPerformSelector: @selector(hoccerClientDidFinishLoading:) withObject: self];
}



#pragma mark -
#pragma mark Private Methods
- (NSString *)transferTypeFromGestureName: (NSString *)name {
	if ([name isEqual:@"throw"] || [name isEqual:@"catch"]) {
		return @"distribute";
	}
	
	if ([name isEqual:@"sweepIn"] || [name isEqual:@"sweepOut"]) {
		return @"pass";
	}
	
	@throw [NSException exceptionWithName:@"UnknownGestureType" reason:[NSString stringWithFormat:@"The gesture %@ is unknown", name] userInfo:nil];
}

#pragma mark -
#pragma mark Private UserInfo Methods 

- (NSError *)createAppropriateError {
	if ([gesture isEqual:@"throw"]) {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoCatcher userInfo:[self userInfoForNoCatcher]];
	}
	
	if ([gesture isEqual:@"catch"]) {
		return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoThrower userInfo:[self userInfoForNoThrower]];
	}
	
	return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageNoSecondSweeper userInfo:[self userInfoForNoSecondSweeper]];
}

- (NSError *)createAppropriateCollisionError {
	return [NSError errorWithDomain:hoccerMessageErrorDomain code:kHoccerMessageCollision userInfo:[self userInfoForInterception]];
}


- (NSDictionary *)userInfoForNoCatcher {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Nobody caught your content!" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:@"You can use hoccer to throw content to someone near you. Timing is important. The other person needs to catch just after you have thrown." forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
	
}

- (NSDictionary *)userInfoForNoThrower {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Nothing was thrown to you!" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:@"You can use hoccer to catch something that was thrown by someone near you. \nTiming is important. You need to catch just after the other person has thrown." forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
	
}

- (NSDictionary *)userInfoForNoSecondSweeper {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"No second device found!" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:@"Asure that you really sweept over the edges of both devices." forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
}

- (NSDictionary *)userInfoForInterception {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Your hoc has been intercepted" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:@"Hoccer wants to guarantee that only the right person gets the content. Unfortunatly someone else tried to hoc at your location. Try it again." forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
}

@end
