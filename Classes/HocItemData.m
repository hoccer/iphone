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
#import "ContentContainerView.h"

#import "HocLocation.h"

#define hoccerMessageErrorDomain @"HoccerErrorDomain"

@interface HocItemData ()

- (NSString *)transferTypeFromGestureName: (NSString *)name;
- (NSArray *)actionButtons;

- (NSDictionary *)userInfoForNoCatcher;
- (NSDictionary *)userInfoForNoThrower;
- (NSDictionary *)userInfoForNoSecondSweeper;
- (NSDictionary *)userInfoForInterception;
- (NSError *)createAppropriateError;
- (NSError *)createAppropriateCollisionError;

@end



@implementation HocItemData

@synthesize content;
@synthesize contentView;
@synthesize viewOrigin;

@synthesize status;
@synthesize delegate;
@synthesize isUpload;
@synthesize gesture;
@synthesize progress;

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
	[status release];
	[progress release];
	
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
		Preview *preview = [content desktopItemView];
		if (preview != nil) {
			contentView = [[ContentContainerView alloc] initWithView:preview actionButtons: [self actionButtons]];
		}
	}
	
	if (contentView == nil) {
		UIView *preview = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)] autorelease];
		preview.backgroundColor = [UIColor whiteColor];

		contentView = [[ContentContainerView alloc] initWithView:preview actionButtons: [self actionButtons]];
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
	
	if ([error code] == 500 || 
		( [[errorResponse objectForKey:@"state"] isEqual:@"no_seeders"] ||
			  [[errorResponse objectForKey:@"state"] isEqual:@"no_peers"] ) )  {
		
		error = [self createAppropriateError];
	} else if ([error code] == 409) {
		error = [self createAppropriateCollisionError];
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

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)theProgress {
	self.progress = theProgress;
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



- (NSArray *)actionButtons {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:[UIImage imageNamed:@"container_btn_double-close.png"] forState:UIControlStateNormal];
	[button addTarget: self action: @selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
	[button setFrame: CGRectMake(0, 0, 65, 61)];
	
	
	UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
	[button2 setImage:[UIImage imageNamed:@"container_btn_double-save.png"] forState:UIControlStateNormal];
	[button2 addTarget: self action: @selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
	[button2 setFrame: CGRectMake(0, 0, 65, 61)];
	
	NSMutableArray *buttons = [NSMutableArray array]; 
	[buttons addObject:button];
	[buttons addObject:button2];
	
	return buttons;
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

#pragma mark -
#pragma mark User Actions
- (IBAction)closeView: (id)sender {
	NSLog(@"close View: %@", nil);
	if ([delegate respondsToSelector:@selector(hocItemWasClosed:)]) {
		[delegate hocItemWasClosed: self];
	} 
}

- (IBAction)saveButton: (id)sender {
	NSLog(@"save: %@", nil);
	[content saveDataToContentStorage];
}




@end
