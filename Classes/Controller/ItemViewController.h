//
//  hoccerControllerData.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemViewControllerDelegate.h"

@class HoccerContent;
@class ContentContainerView;

@interface ItemViewController : NSObject <NSCoding> {
	ContentContainerView *contentView;
	HoccerContent *content;
	
	CGPoint viewOrigin;
	NSString *statusMessage;
	NSNumber *progress;
	NSDictionary *status;

	BOOL isUpload;
	
	id <ItemViewControllerDelegate> delegate;
	
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
@property (nonatomic, assign) id <ItemViewControllerDelegate> delegate; 

- (void)cancelRequest;
- (BOOL)hasActiveRequest;

- (void)removeFromFileSystem;
- (void)updateView;

@end
