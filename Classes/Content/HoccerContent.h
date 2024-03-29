//
//  HoccerContent.h
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TransferController.h"
#import "Crypto.h"

@class Preview;

@interface HoccerContent : NSObject <NSCoding,UIDocumentInteractionControllerDelegate> {
	NSString *filename;	
	BOOL isFromContentSource;
    BOOL canBeCiphered;
	NSString *mimeType;
	
	@private
	NSData *data;
	BOOL persist;
	
	id target;
	SEL selector;
	id context;
	
	UIDocumentInteractionController *interactionController;
    
    id <Cryptor> cryptor;
}

@property (nonatomic, retain) NSData *data; 
@property (copy) NSString *filename;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, readonly) NSURL *fileUrl;
@property (nonatomic, readonly) NSString *filepath;
@property (nonatomic, readonly) NSString *extension;
@property (assign) BOOL isFromContentSource;
@property (assign) BOOL canBeCiphered;
@property (assign) BOOL persist;

@property (readonly) UIDocumentInteractionController *interactionController;
@property (retain, nonatomic) id <Cryptor> cryptor;

@property (readonly) BOOL readyForSending;

- (id) initWithData: (NSData *)theData;
- (id) initWithFilename: (NSString *)filename;
- (id) initWithDictionary: (NSDictionary *)dict;
- (void)removeFromDocumentDirectory;
- (void)saveDataToDocumentDirectory;

- (BOOL)saveDataToContentStorage;

- (UIView *)fullscreenView;
- (UIView *)smallView;
- (Preview *)desktopItemView;

- (NSString *)defaultFilename;

- (BOOL)isDataReady;

- (BOOL)needsWaiting;

- (NSString *)descriptionOfSaveButton;
- (void) saveDataToDocumentDirectory;

- (UIImage *)imageForSaveButton;
- (UIImage *)historyThumbButton;

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector context: (id)aContext;
- (void)sendSaveSuccessEvent;

- (NSDictionary *)dataDesctiption;
- (UIDocumentInteractionController *)interactionController;

- (NSObject <Transferable> *)transferer;
- (NSArray *)transferers;

- (BOOL)presentOpenInViewController: (UIViewController *)controller;
- (void)cryptorWithType: (NSString *)type salt: (NSString *)salt password:(NSString *)password;

- (void)viewDidLoad;

@end
