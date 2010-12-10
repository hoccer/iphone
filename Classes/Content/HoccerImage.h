//
//  HoccerImage.h
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hoccer.h"
#import "HoccerFileContent.h"
#import "TransferController.h"

@interface HoccerImage : HoccerFileContent <HCFileCacheDelegate, Transferable> {
	UIImage *image;	
	
	HCFileCache *fileCache;
	NSString *uploadURL;
	
	Preview *preview;
	
	NSNumber *progress;
	NSError *error;
	TransferableState state;
	
	BOOL shouldUpload;
}

@property (nonatomic, readonly) UIImage* image;

@property (nonatomic, retain) NSNumber* progress;
@property (nonatomic, retain) NSError* error;
@property (nonatomic, assign) TransferableState state;

- (id)initWithUIImage: (UIImage *)aImage;
- (void)uploadFile;
- (void)updateImage;
- (void)didFinishDataRepresentation;


@end
