//
//  HocItemData.h
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HoccerRequest;
@class HoccerContent;
@class Preview;
@class HocLocation;


@interface HocItemData : NSObject {
	HoccerRequest *request;
	Preview *contentView;
	HoccerContent *content;
	
	CGPoint viewOrigin;
	
	NSString *status;
}

@property (retain) HoccerContent *content;
@property (retain) Preview* contentView;
@property (assign) CGPoint viewOrigin;

@property (nonatomic, copy) NSString *status;

- (void)cancelRequest;
- (BOOL)hasActiveRequest;

- (void)uploadWithLocation: (HocLocation *)location gesture: (NSString *)gesture;
- (void)downloadWithLocation: (HocLocation *)location gesture: (NSString *)gesture;

@end
