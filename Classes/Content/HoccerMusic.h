//
//  HoccerVideo.h
//  Hoccer
//
//  Created by Philip Brechler on 29.07.2011
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "Hoccer.h"
#import "HoccerFileContent.h"
#import "TransferController.h"
#import "FileUploader.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioPreview.h"

@interface HoccerMusic : HoccerFileContent <HCFileCacheDelegate,AVAudioPlayerDelegate> {
	MPMediaItem *song;	
	UIImage *thumb;
    
    FileUploader *thumbUploader;
    NSString *thumbURL;

    FileDownloader *thumbDownloader;
    
    AudioPreview *view;
    
    MPMoviePlayerController *fullscreenPlayer;
    BOOL audioFileReady;
}

@property (nonatomic, readonly) MPMediaItem* song;
@property (nonatomic, readonly) AVAsset* recievedSong;
@property (nonatomic, readonly) UIImage* thumb;
@property (retain) IBOutlet AudioPreview *view;
@property (retain) MPMoviePlayerController *fullscreenPlayer;

- (id)initWithMediaItem: (MPMediaItem *)aMediaItem;
- (void)updateImage;
- (void)didFinishDataRepresentation;
- (void)audioExporterFailed:(NSError *)error;

- (NSString *)thumbFilename;
- (NSString *)thumbURL;

@end
