//
//  HocItemData.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HocItemDataDelegate.h"

#define kHoccerMessageNoCatcher 2
#define kHoccerMessageNoThrower 3
#define kHoccerMessageNoSecondSweeper 4
#define kHoccerMessageCollision 5

@class HoccerRequest;
@class HoccerContent;
@class Preview;
@class HocLocation;


@interface HocItemData : NSObject <NSCoding> {
	HoccerRequest *request;
	Preview *contentView;
	HoccerContent *content;
	
	CGPoint viewOrigin;
	NSString *status;

	NSString *gesture;
	BOOL isUpload;
	
	id <HocItemDataDelegate> delegate;
}

@property (retain) HoccerContent *content;
@property (retain) Preview* contentView;
@property (assign) CGPoint viewOrigin;
@property (assign) BOOL isUpload;
@property (retain) NSString *gesture;

@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) id <HocItemDataDelegate> delegate; 

- (void)cancelRequest;
- (BOOL)hasActiveRequest;

- (void)uploadWithLocation: (HocLocation *)location gesture: (NSString *)gesture;
- (void)downloadWithLocation: (HocLocation *)location gesture: (NSString *)gesture;

- (void)removeFromFileSystem;

@end
