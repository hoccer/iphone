//
//  hoccerControllerData.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ItemViewController.h"
#import "HoccerContent.h"
#import "StatusViewController.h"
#import "ContentContainerView.h"
#import "Preview.h"

#import "HCButton.h"

@interface ItemViewController ()

- (NSArray *)actionButtons;

@end


@implementation ItemViewController

@synthesize content;
@synthesize contentView;
@synthesize viewOrigin;

@synthesize delegate;
@synthesize isUpload;

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

#pragma mark -
#pragma mark HoccerConnection Delegate

//- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateStatus: (NSDictionary *)theStatus {
//	self.status = theStatus;
//	self.statusMessage = [theStatus objectForKey:@"message"];
//}
//
//- (void)hoccerConnection: (HoccerConnection *)hoccerConnection didUpdateTransfereProgress: (NSNumber *)theProgress {
//	self.progress = theProgress;
//}

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
	if ([delegate respondsToSelector:@selector(itemViewControllerWasClosed:)]) {
		[delegate itemViewControllerWasClosed: self];
	} 
}

- (IBAction)saveButton: (id)sender {		
	if ([delegate respondsToSelector:@selector(itemViewControllerSaveButtonWasClicked:)]) {
		[delegate itemViewControllerSaveButtonWasClicked: self];
	}
}

@end