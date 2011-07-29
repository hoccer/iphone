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
#import <MediaPlayer/MediaPlayer.h>

@interface HoccerMusic : HoccerFileContent <HCFileCacheDelegate> {
	MPMediaItem *song;	
	
	UIImage *thumb;
	
	Preview *preview;
    
    FileUploader *thumbUploader;
    NSString *thumbURL;
    
    FileDownloader *thumbDownloader;
}

@property (nonatomic, readonly) MPMediaItem* song;
@property (nonatomic, readonly) UIImage* thumb;
@property (readonly) Preview *preview;

- (id)initWithMediaItem: (MPMediaItem *)aMediaItem;
- (void)updateImage;
- (void)didFinishDataRepresentation;
- (void)audioExporterFailed:(NSError *)error;

- (NSString *)thumbFilename;
- (NSString *)thumbURL;

@end
