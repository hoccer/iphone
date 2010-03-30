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


@interface HoccerContent : NSObject {
	NSString *filepath;	
	NSData *data;
	
	HoccerContentIPadPreviewDelegate *previewDelegate;
}

@property (retain) NSData *data; 
@property (retain) NSString* filepath;
@property (nonatomic, readonly) NSString *extension;
@property (nonatomic, readonly) NSURL *fileUrl;

- (id) initWithData: (NSData *)theData filename: (NSString *)filename;
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

@end
