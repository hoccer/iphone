//
//  HocItemData.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HocItemData.h"
#import "HoccerConnection.h"
#import "HoccerClient.h"
#import "HoccerRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerUploadConnection.h"
#import "HoccerDownloadConnection.h"
#import "HoccerContent.h"
#import "HoccerContentFactory.h"
#import "StatusViewController.h"
#import "ContentContainerView.h"
#import "Preview.h"
#import "HoccerImage.h"

#import "HocLocation.h"

#define hoccerMessageErrorDomain @"HoccerErrorDomain"


@interface HocItemData ()

- (NSString *)transferTypeFromGestureName: (NSString *)name;
- (NSArray *)actionButtons;

- (void)setUpHoccerClient;

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

@synthesize viewFromNib;

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self setUpHoccerClient];
	}
	return self;
}



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
	[hoccerClient release];
	
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

- (ContentContainerView *)contentView {
	if (contentView == nil) {
		Preview *preview = [content desktopItemView];
		if (preview != nil) {
			contentView = [[ContentContainerView alloc] initWithView:preview actionButtons: [self actionButtons]];
		}
	}
	
	if (contentView == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EmptyContent" owner:self options:nil];
		Preview *preview = (Preview *)viewFromNib;
		viewFromNib = nil;
		preview.allowsOverlay = NO;
		contentView = [[ContentContainerView alloc] initWithView:preview actionButtons: [self actionButtons]];
	}
	
	return contentView;
}

- (void)sweepOutWithLocation: (HocLocation *)location {
	if ([delegate respondsToSelector:@selector(hocItemWillStartUpload:)]) {
		[delegate hocItemWillStartUpload:self];
	}
	
	[content prepareSharing];
	request = [hoccerClient connectionWithRequest:[HoccerRequest sweepOutWithContent:self.content location:location]];
	isUpload = YES;
}

- (void)throwWithLocation: (HocLocation *)location {
	if ([delegate respondsToSelector:@selector(hocItemWillStartUpload:)]) {
		[delegate hocItemWillStartUpload:self];
	}
	
	[content prepareSharing];
	NSLog(@"hoccerClient: %@", hoccerClient);
	request = [hoccerClient connectionWithRequest:[HoccerRequest throwWithContent:self.content location:location]];
	isUpload = YES;
}

- (void)downloadWithLocation:(HocLocation *)location gesture:(NSString *)aGesture {
	if ([delegate respondsToSelector:@selector(hocItemWillStartDownload:)]) {
		[delegate hocItemWillStartDownload:self];
	}
	
	self.gesture = aGesture;
	request = [[HoccerDownloadConnection alloc] initWithLocation: location gesture:[self transferTypeFromGestureName:gesture] delegate: self];
	isUpload = NO;
}


#pragma mark -
#pragma mark Download Communication
- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest {
	HoccerContent* hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: aRequest.response 
																									   withData: aRequest.result];
	hoccerContent.persist = YES;
	
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
	
	self.content.persist = YES;
	if ([delegate respondsToSelector:@selector(hocItemWasSend:)]) {
		[delegate hocItemWasSend: self];
	}
}

#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update {
	self.status = update;
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)theProgress {
	self.progress = theProgress;
}



#pragma mark -
#pragma mark HoccerConnection Delegate
- (void)hoccerConnection: (HoccerConnection*)hoccerConnection didFailWithError: (NSError *)error {
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

- (void)hoccerConnectionDidFinishLoading: (HoccerConnection*)hoccerConnection {
	[request release];
	request = nil;
		
	if (isUpload) {
		self.content.persist = YES;
		if ([delegate respondsToSelector:@selector(hocItemWasSend:)]) {
			[delegate hocItemWasSend: self];
		}
	} else {
		if ([delegate respondsToSelector:@selector(hocItemWasReceived:)]) {
			HoccerContent* hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: hoccerConnection.responseHeader 
																											   withData: hoccerConnection.responseBody];
			self.content = hoccerContent;
			self.content.persist = YES;

			[delegate hocItemWasReceived:self];
		}
	}
	

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
	if (content.isFromContentSource) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setImage:[UIImage imageNamed:@"container_btn_single-close.png"] forState:UIControlStateNormal];
		[button addTarget: self action: @selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
		[button setFrame: CGRectMake(0, 0, 65, 61)];
		
		NSMutableArray *buttons = [NSMutableArray array]; 
		[buttons addObject:button];
		
		return buttons;
	} else {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setImage:[UIImage imageNamed:@"container_btn_double-close.png"] forState:UIControlStateNormal];
		[button addTarget: self action: @selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
		[button setFrame: CGRectMake(0, 0, 65, 61)];
		
		UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
		[button2 setImage:[content imageForSaveButton] forState:UIControlStateNormal];
		[button2 addTarget: self action: @selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
		[button2 setFrame: CGRectMake(0, 0, 65, 61)];
		
		NSMutableArray *buttons = [NSMutableArray array]; 
		[buttons addObject:button];
		[buttons addObject:button2];
		
		return buttons;
	}
}

- (void)setUpHoccerClient {
	hoccerClient = [[HoccerClient alloc] init];
	hoccerClient.userAgent = @"Hoccer/iPhone";
	hoccerClient.delegate = self;
}

@end
