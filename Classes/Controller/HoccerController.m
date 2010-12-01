//
//  hoccerControllerData.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerController.h"
#import "HoccerContent.h"
#import "HoccerContentFactory.h"
#import "StatusViewController.h"
#import "ContentContainerView.h"
#import "Preview.h"
#import "HoccerImage.h"

#import "HocLocation.h"
#import "HCButton.h"

#define hoccerMessageErrorDomain @"HoccerErrorDomain"


@interface HoccerController ()

- (NSArray *)actionButtons;

@end


@implementation HoccerController

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
	[gesture release];
	[statusMessage release];
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
//	[request cancel];
//	self.request = nil;
//	
//	if (isUpload) {
//		if ([delegate respondsToSelector:@selector(hoccerControllerUploadWasCanceled:)]) {
//			[delegate hoccerControllerUploadWasCanceled:self];
//		}
//	} else {
//		if ([delegate respondsToSelector:@selector(hoccerControllerDownloadWasCanceled:)]) {
//			[delegate hoccerControllerDownloadWasCanceled:self];
//		}
//	}
}

- (BOOL)hasActiveRequest {
//	return self.request != nil;
	return NO;
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

- (void)sweepOutWithLinccer: (HCLinccer *)linccer {
	if ([delegate respondsToSelector:@selector(hoccerControllerWillStartUpload:)]) {
		[delegate hoccerControllerWillStartUpload:self];
	}
	
	[content prepareSharing];
	
	NSDictionary *data = [NSDictionary dictionaryWithObject:@"Hello" forKey:@"message"];
	linccer.delegate = self;
	[linccer send:data withMode:HCTransferModeOneToOne];
	
	isUpload = YES;
}

- (void)throwWithLinccer: (HCLinccer *)linccer {
	if ([delegate respondsToSelector:@selector(hoccerControllerWillStartUpload:)]) {
		[delegate hoccerControllerWillStartUpload:self];
	}
	
	[content prepareSharing];
	NSDictionary *data = [NSDictionary dictionaryWithObject:@"Hello" forKey:@"message"];
	linccer.delegate = self;
	[linccer send:data withMode:HCTransferModeOneToMany];
	
	isUpload = YES;
}

- (void)catchWithLinccer: (HCLinccer *)linccer {
	if ([delegate respondsToSelector:@selector(hoccerControllerWillStartDownload:)]) {
		[delegate hoccerControllerWillStartDownload:self];
	}
	
	linccer.delegate = self;
	[linccer receiveWithMode:HCTransferModeOneToMany];
	isUpload = NO;
}

- (void)sweepInWithLinccer:(HCLinccer *)linccer {
	if ([delegate respondsToSelector:@selector(hoccerControllerWillStartDownload:)]) {
		[delegate hoccerControllerWillStartDownload:self];
	}
	
	linccer.delegate = self;
	[linccer receiveWithMode:HCTransferModeOneToOne];
	isUpload = NO;
}

#pragma mark -
#pragma mark HoccerConnection Delegate

//- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateStatus: (NSDictionary *)theStatus {
//	self.status = theStatus;
//	self.statusMessage = [theStatus objectForKey:@"message"];
//}

//- (void)hoccerConnection: (HoccerConnection*)hoccerConnection didFailWithError: (NSError *)error {
//	self.statusMessage = [error localizedDescription];
//	
//	if (isUpload) {
//		if ([delegate respondsToSelector:@selector(hoccerController:uploadFailedWithError:)]) {
//			[delegate hoccerController:self uploadFailedWithError: error];
//		}
//	} else {
//		if ([delegate respondsToSelector:@selector(hoccerController:downloadFailedWithError:)]) {
//			[delegate hoccerController:self downloadFailedWithError:error];
//		}
//	}
//}
//
//- (void)hoccerConnectionDidFinishLoading: (HoccerConnection*)hoccerConnection {
//	if (isUpload) {
//		if ([delegate respondsToSelector:@selector(hoccerControllerWasSent:)]) {
//			[delegate hoccerControllerWasSent: self];
//		}
//	} else {
//		if ([delegate respondsToSelector:@selector(hoccerControllerWasReceived:)]) {
//			HoccerContent* hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: hoccerConnection.responseHeader 
//																											   withData: hoccerConnection.responseBody];
//			self.request = nil;
//			self.content = hoccerContent;
//			self.content.persist = YES;
//			
//			[delegate hoccerControllerWasReceived:self];
//		}
//	}
//}
//
//- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateTransfereProgress: (NSNumber *)theProgress {
//	self.progress = theProgress;
//}

- (void)linccer:(HCLinccer *)linccer didFailWithError:(NSError *)error {
	NSLog(@"error %@", error);
}

- (void) linccer:(HCLinccer *)linncer didReceiveData:(NSArray *)data {
	if ([delegate respondsToSelector:@selector(hoccerControllerWasReceived:)]) {
		HoccerContent* hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: nil 
																										   withData: nil];
		self.content = hoccerContent;
		self.content.persist = YES;
		
		[delegate hoccerControllerWasReceived:self];
	}
}


#pragma mark -
#pragma mark Private Methods

- (NSArray *)actionButtons {
	if (content.isFromContentSource) {
		UIButton *button = [HCButton buttonWithType:UIButtonTypeCustom];
		[button setBackgroundImage:[UIImage imageNamed:@"container_btn_single-close.png"] forState:UIControlStateNormal];
		[button setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
		[button addTarget: self action: @selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
		[button setFrame: CGRectMake(0, 0, 65, 61)];
		
		NSMutableArray *buttons = [NSMutableArray array]; 
		[buttons addObject:button];
		
		return buttons;
	} else {
		HCButton *button = [HCButton buttonWithType:UIButtonTypeCustom];
		[button setBackgroundImage:[UIImage imageNamed:@"container_btn_double-close.png"] forState:UIControlStateNormal];
		[button addTarget: self action: @selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
		[button setTextLabelOffset:3];
		[button setFrame: CGRectMake(0, 0, 65, 61)];
		
		HCButton *button2 = [HCButton buttonWithType:UIButtonTypeCustom];
		[button2 setBackgroundImage:[content imageForSaveButton] forState:UIControlStateNormal];
		[button2 addTarget:self action: @selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
		[button2 setTitle: [content descriptionOfSaveButton] forState:UIControlStateNormal];
		[button2 setTextLabelOffset:-2];
		[button2 setFrame: CGRectMake(0, 0, 65, 61)];
		
		NSArray *buttons = [NSArray arrayWithObjects:button, button2, nil]; 
		
		return buttons;
	}
}

#pragma mark -
#pragma mark User Actions
- (IBAction)closeView: (id)sender {
	if ([delegate respondsToSelector:@selector(hoccerControllerWasClosed:)]) {
		[delegate hoccerControllerWasClosed: self];
	} 
}

- (IBAction)saveButton: (id)sender {		
	if ([delegate respondsToSelector:@selector(hoccerControllerSaveButtonWasClicked:)]) {
		[delegate hoccerControllerSaveButtonWasClicked: self];
	}
	
	

}

@end
