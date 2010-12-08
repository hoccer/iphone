//
//  HoccerImage.h
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hoccer.h"
#import "HoccerContent.h"
#import "DownloadController.h"

@interface HoccerImage : HoccerContent <HCFileCacheDelegate, Downloadable> {
	UIImage *image;	
	
	HCFileCache *fileCache;
	NSString *uploadURL;
	
	Preview *preview;
	
	NSNumber *progress;
	NSError *error;
	NSInteger state;
	
	BOOL shouldUpload;
}

@property (nonatomic, readonly) UIImage* image;

@property (nonatomic, retain) NSNumber* progress;
@property (nonatomic, retain) NSError* error;
@property (nonatomic, assign) NSInteger state;

- (id)initWithUIImage: (UIImage *)aImage;
- (void)uploadFile;
- (void)updateImage;
- (void)didFinishDataRepresentation;


@end
