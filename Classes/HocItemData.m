//
//  HocItemData.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HocItemData.h"
#import "HoccerRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerUploadRequest.h"
#import "HoccerDownloadRequest.h"
#import "HoccerContent.h"
#import "HoccerContentFactory.h"
#import "StatusViewController.h"
#import "Preview.h"

#import "HocLocation.h"

#define hoccerMessageErrorDomain @"HoccerErrorDomain"

@interface HocItemData ()

- (NSString *)transferTypeFromGestureName: (NSString *)name;
- (NSDictionary *)userInfoForNoCatcher;
- (NSDictionary *)userInfoForNoThrower;
- (NSDictionary *)userInfoForNoSecondSweeper;
- (NSError *)createAppropriateError;

@end



@implementation HocItemData

@synthesize content;
@synthesize contentView;
@synthesize viewOrigin;

@synthesize status;
@synthesize delegate;
@synthesize isUpload;
@synthesize gesture;

#pragma mark NSCoding Delegate Methods
- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self != nil) {
		content = [[decoder decodeObjectForKey:@"content"] retain];
		viewOrigin = [decoder decodeCGPointForKey:@"position"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:content forKey:@"content"];
	[encoder encodeCGPoint:viewOrigin forKey:@"position"];
}

- (void) dealloc {
	[content release];
	[contentView release];
	[request release];
	[gesture release];
	
	[super dealloc];
}

- (void)setContent:(HoccerContent *)newContent {
	if (content != newContent) {
		[content release];
		content = [newContent retain];
	}
	
	self.contentView = nil;
}

- (void)removeFromFileSystem {
	[content removeFromDocumentDirectory];
}

- (void)cancelRequest {
	if (request == nil) {
		return;
	}
	
	[request cancel];
	[request release];
	request = nil;

	if (isUpload) {
		if ([delegate respondsToSelector:@selector(hocItemUploadWasCanceled:)]) {
			[delegate hocItemUploadWasCanceled:self];
		}
	} else {
		if ([delegate respondsToSelector:@selector(hocItemDownloadWasCanceled:)]) {
			[delegate hocItemDownloadWasCanceled:self];
		}
	}
}

- (BOOL)hasActiveRequest {
	return request != nil;
}

- (Preview *)contentView {
	if (contentView == nil) {
		contentView = [[content desktopItemView] retain];
	}
	
	if (contentView == nil) {
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
		contentView.backgroundColor = [UIColor whiteColor];
	}
	
	return contentView;
}

- (void)uploadWithLocation: (HocLocation *)location gesture: (NSString *)aGesture {
	if ([delegate respondsToSelector:@selector(hocItemWillStartUpload:)]) {
		[delegate hocItemWillStartUpload:self];
	}
	
	self.gesture = aGesture;
	[content prepareSharing];
	request = [[HoccerUploadRequest alloc] initWithLocation:location gesture:[self transferTypeFromGestureName:gesture] content: content 
													   type: [content mimeType] filename: [content filename] delegate:self];
	
	isUpload = YES;
}

- (void)downloadWithLocation:(HocLocation *)location gesture:(NSString *)aGesture {
	if ([delegate respondsToSelector:@selector(hocItemWillStartDownload:)]) {
		[delegate hocItemWillStartDownload:self];
	}
	
	self.gesture = aGesture;
	request = [[HoccerDownloadRequest alloc] initWithLocation: location gesture:[self transferTypeFromGestureName:gesture] delegate: self];
	isUpload = NO;
}


#pragma mark -
#pragma mark Download Communication
- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest {
	HoccerContent* hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: aRequest.response 
																									   withData: aRequest.result];
	
	self.content = hoccerContent;	
	[request release];
	request = nil;
	
	if ([delegate respondsToSelector:@selector(hocItemWasReceived:)]) {
		[delegate hocItemWasReceived:self];
	}
}

#pragma mark -
#pragma mark Upload Communication 

- (void)requestDidFinishUpload: (BaseHoccerRequest *)aRequest {
	[request release];
	request = nil;
	
	if ([delegate respondsToSelector:@selector(hocItemWasSend:)]) {
		[delegate hocItemWasSend: self];
	}
}

#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	NSDictionary *errorResponse = [[error userInfo] objectForKey:@"HoccerErrorDescription"];
	NSLog(@"errorResponse :%@", errorResponse);
	
	if ([error code] == 500 && 
			( [[errorResponse objectForKey:@"state"] isEqual:@"no_seeders"] ||
			  [[errorResponse objectForKey:@"state"] isEqual:@"no_peers"] ) ) {
		
		error = [self createAppropriateError];
	}
	
	self.status = [error localizedDescription];
	[request release];
	request = nil;
	
	if (isUpload) {
		if ([delegate respondsToSelector:@selector(hocItem:uploadFailedWithError:)]) {
			[delegate hocItem:self uploadFailedWithError: error];
		}
	} else {
		if ([delegate respondsToSelector:@selector(hocItem:downloadFailedWithError:)]) {
			[delegate hocItem:self downloadFailedWithError:error];
		}
	}
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update {
	self.status = update;
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress {
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
									  
	@throw [NSException exceptionWithName:@"UnknownGestureType" reason:@"The gesture to transfer is unknown"  userInfo:nil];
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

- (NSDictionary *)userInfoForNoCatcher {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Nobody caught your content!" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:@"You can use hoccer to throw content to someone near you. Timing is important. The other person needs to catch just after you have thrown." forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
	
}

- (NSDictionary *)userInfoForNoThrower {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"Nothing was thrown to you!" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:@"You can use hoccer to catch something that way thrown by someone near you. Timing is important. You need to catch just after the other person has thrown." forKey:NSLocalizedRecoverySuggestionErrorKey];

	return [userInfo autorelease];
	
}

- (NSDictionary *)userInfoForNoSecondSweeper {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"No second sweeper was found!" forKey:NSLocalizedDescriptionKey];
	[userInfo setObject:@"Asure that you really sweept over the edges of both devices." forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [userInfo autorelease];
}


@end
