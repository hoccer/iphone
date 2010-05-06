//
//  HocItemData.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HocItemDataDelegate.h"
#import "HoccerConnectionDelegate.h"

@class HoccerConnection;
@class HoccerContent;
@class ContentContainerView;
@class HocLocation;
@class HoccerClient;

@interface HocItemData : NSObject <NSCoding, HoccerConnectionDelegate> {
	HoccerConnection *request;
	ContentContainerView *contentView;
	HoccerContent *content;
	
	CGPoint viewOrigin;
	NSString *status;
	NSNumber *progress;

	NSString *gesture;
	BOOL isUpload;
	
	HoccerClient *hoccerClient;
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

- (void)sweepOutWithLocation: (HocLocation *)location;
- (void)throwWithLocation: (HocLocation *)location;

- (void)downloadWithLocation: (HocLocation *)location gesture: (NSString *)gesture;

- (void)removeFromFileSystem;

@end
