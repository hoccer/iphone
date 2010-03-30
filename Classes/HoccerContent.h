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


@interface HoccerContent : NSObject{
	NSString *filepath;	
	NSData *data;
}

@property (retain) NSData *data; 
@property (retain) NSString* filepath;

- (id) initWithData: (NSData *)theData filename: (NSString *)filename;
- (void) removeFromDocumentDirectory;
- (void) setData:(NSData *) theData filename: (NSString*) aFilename;

- (void)save;
- (UIView *)fullscreenView;
- (Preview *)desktopItemView;

- (NSString *)filename;
- (NSString *)mimeType;

- (BOOL)isDataReady;

- (BOOL)needsWaiting;
- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector;

- (NSString *)saveButtonDescription;

@end
