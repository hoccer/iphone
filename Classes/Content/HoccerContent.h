//
//  HoccerData.h
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"

@class Preview;
@class HoccerContentIPadPreviewDelegate;

@interface HoccerContent : NSObject <NSCoding> {
	NSString *filename;	
	BOOL isFromContentSource;
	
	@private
	NSData *data;
	BOOL persist;
	NSString *mimeType;
	
	
	id interactionController;
}

@property (retain) NSData *data; 
@property (retain) NSString *filename;
@property (retain) NSString *mimeType;
@property (nonatomic, readonly) NSURL *fileUrl;
@property (nonatomic, readonly) NSString *filepath;
@property (nonatomic, readonly) NSString *extension;
@property (assign) BOOL isFromContentSource;
@property (assign) BOOL persist;
@property (readonly) id interactionController;

+ (NSString *)contentDirectory;

- (id) initWithData: (NSData *)theData filename: (NSString *)filename;
- (id) initWithFilename: (NSString *)filename;
- (void) removeFromDocumentDirectory;
- (void) saveDataToDocumentDirectory;

- (BOOL)saveDataToContentStorage;

- (UIView *)fullscreenView;
- (Preview *)desktopItemView;

- (NSString *)defaultFilename;

- (BOOL)isDataReady;
- (void)prepareSharing;

- (BOOL)needsWaiting;

- (NSString *)descriptionOfSaveButton;
- (void) saveDataToDocumentDirectory;

- (NSString *)uniqueFilenameForFilename: (NSString *)theFilename inDirectory: (NSString *)directory;
- (UIImage *)imageForSaveButton;
- (UIImage *)historyThumbButton;

- (id)interactionController;

@end
