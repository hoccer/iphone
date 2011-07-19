//
//  HoccerData.h
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"
#import "TransferController.h"
#import "Crypto.h"

@class Preview;

@interface HoccerContent : NSObject <NSCoding> {
	NSString *filename;	
	BOOL isFromContentSource;
	NSString *mimeType;
	
	@private
	NSData *data;
	BOOL persist;
    PublicKeyManager *keyManager;
	
	id target;
	SEL selector;
	id context;
	
	id interactionController;
    
    id <Cryptor> cryptor;
}

@property (nonatomic, retain) NSData *data; 
@property (copy) NSString *filename;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, readonly) NSURL *fileUrl;
@property (nonatomic, readonly) NSString *filepath;
@property (nonatomic, readonly) NSString *extension;
@property (assign) BOOL isFromContentSource;
@property (assign) BOOL persist;

@property (readonly) id interactionController;
@property (retain, nonatomic) id <Cryptor> cryptor;

@property (readonly) BOOL readyForSending;

- (id) initWithData: (NSData *)theData;
- (id) initWithFilename: (NSString *)filename;
- (id) initWithDictionary: (NSDictionary *)dict;
- (void)removeFromDocumentDirectory;
- (void)saveDataToDocumentDirectory;

- (BOOL)saveDataToContentStorage;

- (UIView *)fullscreenView;
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
- (id)interactionController;

- (NSObject <Transferable> *)transferer;
- (NSArray *)transferers;

- (BOOL)presentOpenInViewController: (UIViewController *)controller;
- (void)cryptorWithType: (NSString *)type salt: (NSString *)salt password:(NSString *)password;

- (void)viewDidLoad;

@end
