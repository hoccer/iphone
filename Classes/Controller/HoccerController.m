//
//  hoccerControllerData.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerController.h"
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


@interface HoccerController ()
@property (retain) HoccerConnection *request;

- (NSString *)transferTypeFromGestureName: (NSString *)name;
- (NSArray *)actionButtons;

- (void)setUpHoccerClient;

@end


@implementation HoccerController

@synthesize request;
@synthesize content;
@synthesize contentView;
@synthesize viewOrigin;

@synthesize delegate;
@synthesize isUpload;
@synthesize gesture;

@synthesize statusMessage;
@synthesize progress;
@synthesize status;

@synthesize viewFromNib;

- (id) init {
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
	self.request = nil;
	
	[content release];
	[contentView release];
	[gesture release];
	[statusMessage release];
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
	if (self.request == nil) {
		return;
	}
	
	[request cancel];
	self.request = nil;
	
	if (isUpload) {
		if ([delegate respondsToSelector:@selector(hoccerControllerUploadWasCanceled:)]) {
			[delegate hoccerControllerUploadWasCanceled:self];
		}
	} else {
		if ([delegate respondsToSelector:@selector(hoccerControllerDownloadWasCanceled:)]) {
			[delegate hoccerControllerDownloadWasCanceled:self];
		}
	}
}

- (BOOL)hasActiveRequest {
	return self.request != nil;
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
	if ([delegate respondsToSelector:@selector(hoccerControllerWillStartUpload:)]) {
		[delegate hoccerControllerWillStartUpload:self];
	}
	
	[content prepareSharing];
	self.request = [hoccerClient connectionWithRequest:[HoccerRequest sweepOutWithContent:self.content location:location]];
	isUpload = YES;
}

- (void)throwWithLocation: (HocLocation *)location {
	if ([delegate respondsToSelector:@selector(hoccerControllerWillStartUpload:)]) {
		[delegate hoccerControllerWillStartUpload:self];
	}
	
	[content prepareSharing];
	self.request = [hoccerClient connectionWithRequest:[HoccerRequest throwWithContent:self.content location:location]];
	isUpload = YES;
}

- (void)catchWithLocation: (HocLocation *)location {
	if ([delegate respondsToSelector:@selector(hoccerControllerWillStartDownload:)]) {
		[delegate hoccerControllerWillStartDownload:self];
	}
	
	self.request = [hoccerClient connectionWithRequest:[HoccerRequest catchWithLocation: location]];
	isUpload = NO;
}

- (void)sweepInWithLocation:(HocLocation *)location {
	if ([delegate respondsToSelector:@selector(hoccerControllerWillStartDownload:)]) {
		[delegate hoccerControllerWillStartDownload:self];
	}
	
	self.request = [hoccerClient connectionWithRequest:[HoccerRequest sweepInWithLocation: location]];
	isUpload = NO;
}

#pragma mark -
#pragma mark HoccerConnection Delegate

- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateStatus: (NSDictionary *)theStatus {
	self.status = theStatus;
	self.statusMessage = [theStatus objectForKey:@"message"];
}

- (void)hoccerConnection: (HoccerConnection*)hoccerConnection didFailWithError: (NSError *)error {
	self.statusMessage = [error localizedDescription];
	self.request = nil;
	
	if (isUpload) {
		if ([delegate respondsToSelector:@selector(hoccerController:uploadFailedWithError:)]) {
			[delegate hoccerController:self uploadFailedWithError: error];
		}
	} else {
		if ([delegate respondsToSelector:@selector(hoccerController:downloadFailedWithError:)]) {
			[delegate hoccerController:self downloadFailedWithError:error];
		}
	}
}

- (void)hoccerConnectionDidFinishLoading: (HoccerConnection*)hoccerConnection {
	if (isUpload) {
		self.request = nil;
		if ([delegate respondsToSelector:@selector(hoccerControllerWasSent:)]) {
			[delegate hoccerControllerWasSent: self];
		}
	} else {
		if ([delegate respondsToSelector:@selector(hoccerControllerWasReceived:)]) {
			HoccerContent* hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: hoccerConnection.responseHeader 
																											   withData: hoccerConnection.responseBody];
			self.request = nil;
			self.content = hoccerContent;
			self.content.persist = YES;
			
			[delegate hoccerControllerWasReceived:self];
		}
	}
}

- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateTransfereProgress: (NSNumber *)theProgress {
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
		[button2 setBackgroundImage:[content imageForSaveButton] forState:UIControlStateNormal];
		[button2 addTarget: self action: @selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
		[button2 setTitle:@"Open" forState:UIControlStateNormal];
		[button2 setFrame: CGRectMake(0, 0, 65, 61)];
		NSLog(@"title frame: %@", NSStringFromCGRect(button2.titleLabel.frame));
		button2.titleLabel.font = [UIFont systemFontOfSize:10];
		button2.titleLabel.frame = CGRectMake(button2.titleLabel.frame.origin.x, button2.frame.size.height - 23, 
											  button2.titleLabel.frame.size.width, button2.titleLabel.frame.size.height); 
		
		NSMutableArray *buttons = [NSMutableArray arrayWithObjects:button, button2, nil]; 
		
		return buttons;
	}
}

- (void)setUpHoccerClient {
	hoccerClient = [[HoccerClient alloc] init];
	hoccerClient.userAgent = @"Hoccer/iPhone";
	hoccerClient.delegate = self;
}

#pragma mark -
#pragma mark User Actions
- (IBAction)closeView: (id)sender {
	if ([delegate respondsToSelector:@selector(hoccerControllerWasClosed:)]) {
		[delegate hoccerControllerWasClosed: self];
	} 
}

- (IBAction)saveButton: (id)sender {
	if ([delegate respondsToSelector:@selector(showOptionsForContent:)]) {
		[delegate showOptionsForContent: self.content];
	}
	
	
//	if ([content isKindOfClass:[HoccerImage class]]) {
//		[(HoccerImage* )content whenReadyCallTarget:self selector:@selector(finishedSaving)];
//		[self.contentView showSpinner];
//	}
//	
//	[content saveDataToContentStorage];	
}

- (void)finishedSaving {
	[self.contentView hideSpinner];
	[self.contentView showSuccess];
}
	



@end
