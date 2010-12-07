//
//  hoccerControllerData.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hoccerControllerDataDelegate.h"
#import "Hoccer.h"

@class HoccerContent;
@class ContentContainerView;

@interface HoccerController : NSObject <NSCoding, HCLinccerDelegate> {
	ContentContainerView *contentView;
	HoccerContent *content;
	
	CGPoint viewOrigin;
	NSString *statusMessage;
	NSNumber *progress;
	NSDictionary *status;

	BOOL isUpload;
	
	id <HoccerControllerDelegate> delegate;
	
	UIView *viewFromNib;
}

@property (retain) HoccerContent *content;

@property (retain) ContentContainerView* contentView;
@property (assign) CGPoint viewOrigin;
@property (assign) BOOL isUpload;

@property (retain) NSNumber *progress;
@property (nonatomic, copy) NSString *statusMessage;
@property (nonatomic, retain) NSDictionary *status;

@property (assign) IBOutlet UIView* viewFromNib;
@property (nonatomic, assign) id <HoccerControllerDelegate> delegate; 

- (void)cancelRequest;
- (BOOL)hasActiveRequest;

- (void)removeFromFileSystem;

@end
