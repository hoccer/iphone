//
//  HoccerVideo.h
//  Hoccer
//
//  Created by Philip Brechler on 29.07.2011
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hoccer.h"
#import "HoccerFileContent.h"
#import "TransferController.h"
#import "FileUploader.h"

@interface HoccerVideo : HoccerFileContent <HCFileCacheDelegate> {
	NSURL *videoURL;	
	
	UIImage *thumb;
	
	Preview *preview;
    
    FileUploader *thumbUploader;
    NSString *thumbURL;
    
    FileDownloader *thumbDownloader;
}

@property (nonatomic, readonly) NSURL* videoURL;
@property (nonatomic, readonly) UIImage* thumb;
@property (readonly) Preview *preview;

- (id)initWithURL: (NSURL *)aURL;
- (void)updateImage;
- (void)didFinishDataRepresentation;

- (NSString *)thumbFilename;
- (NSString *)thumbURL;

@end
