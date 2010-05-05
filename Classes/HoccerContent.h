//
//  HoccerData.h
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"
#import "HoccerContentPreviewDelegate.h"

@class Preview;
@class HoccerContentIPadPreviewDelegate;

@interface HoccerContent : NSObject <NSCoding> {
	NSString *filepath;	
	id <HoccerContentPreviewDelegate> previewDelegate;
	BOOL isFromContentSource;
	
	@private
	NSData *data;
	
	BOOL persist;
}

@property (retain) NSData *data; 
@property (retain) NSString* filepath;
@property (nonatomic, readonly) NSString *extension;
@property (nonatomic, readonly) NSURL *fileUrl;
@property (assign) BOOL isFromContentSource;
@property (assign) BOOL persist;

- (id) initWithData: (NSData *)theData filename: (NSString *)filename;
- (id) initWithFilename: (NSString *)filename;
- (void) removeFromDocumentDirectory;
- (void) saveDataToDocumentDirectory;

- (void)saveDataToContentStorage;

- (UIView *)fullscreenView;
- (Preview *)desktopItemView;

- (NSString *)filename;
- (NSString *)mimeType;

- (BOOL)isDataReady;
- (void)prepareSharing;

- (BOOL)needsWaiting;

- (NSString *)descriptionOfSaveButton;
- (void) saveDataToDocumentDirectory;

- (void)decorateViewWithGestureRecognition: (UIView *)view inViewController: (UIViewController *)viewController;
- (void)previewInViewController: (UIViewController *)viewController;

- (NSString *)uniqueFilenameFromFilename: (NSString *)filename;
- (UIImage *)imageForSaveButton;

@end
