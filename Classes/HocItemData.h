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
@class ContentContainerView;
@class HocLocation;


@interface HocItemData : NSObject <NSCoding> {
	HoccerRequest *request;
	ContentContainerView *contentView;
	HoccerContent *content;
	
	CGPoint viewOrigin;
	NSString *status;
	NSNumber *progress;

	NSString *gesture;
	BOOL isUpload;
	
	id <HocItemDataDelegate> delegate;
	
	UIView *viewFromNib;
}

@property (retain) HoccerContent *content;
@property (retain) ContentContainerView* contentView;
@property (assign) CGPoint viewOrigin;
@property (assign) BOOL isUpload;
@property (retain) NSString *gesture;
@property (retain) NSNumber *progress;

@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) id <HocItemDataDelegate> delegate; 
@property (assign) IBOutlet UIView* viewFromNib;

- (void)cancelRequest;
- (BOOL)hasActiveRequest;

- (void)uploadWithLocation: (HocLocation *)location gesture: (NSString *)gesture;
- (void)downloadWithLocation: (HocLocation *)location gesture: (NSString *)gesture;

- (void)removeFromFileSystem;

@end
