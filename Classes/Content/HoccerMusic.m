//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerMusic.h"
#import "NSString+URLHelper.h"
#import "Hoccer.h"
#import "Preview.h"
#import "AudioPreview.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

#import "FileDownloader.h"
#import "DelayedFileUploaded.h"

#import "NSFileManager+FileHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface HoccerMusic ()

- (void)createThumb;

@end

@implementation HoccerMusic
@synthesize song,recievedSong;
@synthesize thumb;
@synthesize view;

- (id) initWithFilename:(NSString *)theFilename {
	self = [super initWithFilename:theFilename];
	if (self != nil) {
        
                
	}
	
	return self;	
}



- (id) initWithDictionary:(NSDictionary *)dict {
	self = [super initWithDictionary:dict];
	if (self != nil) {        
        NSArray *previews = [dict objectForKey:@"preview"];
        if (previews && [previews count] > 0) {
            thumbURL = [[[previews objectAtIndex:0] objectForKey:@"uri"] copy];
            thumbDownloader = [[FileDownloader alloc] initWithURL:thumbURL filename:nil];
            thumbDownloader.cryptor = self.cryptor;
            
            [transferables addObject:thumbDownloader];
        }
	}
	
	return self;
}




- (id)initWithMediaItem: (MPMediaItem *)aMediaItem{
	self = [super init];
	if (self != nil) {
		song = [aMediaItem retain];
		isFromContentSource = YES;
		
		[self performSelectorInBackground:@selector(createDataRepresentaion:) withObject:self];
	}
	
	return self;
}

- (void)createDataRepresentaion: (HoccerMusic *)content {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];

    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: songAsset
                                      presetName: AVAssetExportPresetAppleM4A];
    
    NSString *exportFile = [[[NSFileManager defaultManager]contentDirectory] stringByAppendingPathComponent: [[NSFileManager defaultManager]uniqueFilenameForFilename: self.filename inDirectory:[[NSFileManager defaultManager]contentDirectory]]]; 
    
    exporter.outputURL = [[NSURL fileURLWithPath:exportFile] retain];
    exporter.outputFileType = AVFileTypeAppleM4A;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                // log error to text view
                NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@",
                       exportError);
                [self audioExporterFailed:exportError];
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                NSLog (@"AVAssetExportSessionStatusCompleted");
                content.data = [NSData dataWithContentsOfURL:exporter.outputURL];
                [content saveDataToDocumentDirectory];
                audioFileReady = YES;
                [self performSelectorOnMainThread:@selector(didFinishDataRepresentation) withObject:nil waitUntilDone:YES];
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
                NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
            case AVAssetExportSessionStatusExporting: {
                NSLog (@"AVAssetExportSessionStatusExporting"); break;}
            case AVAssetExportSessionStatusCancelled: {
                NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
            case AVAssetExportSessionStatusWaiting: {
                NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
            default: { NSLog (@"didn't get export status"); break;}
        }
    }];
    
    
	
	[pool drain];
}

- (void)didFinishDataRepresentation {
    for (DelayedFileUploaded *transferable in transferables) {
        [transferable setFileReady:YES];
    }
}

- (void)audioExporterFailed:(NSError *)error {
    for (DelayedFileUploaded *transferable in transferables) {
        [transferable setError:error];
    }
    
}
- (void)updateImage {    
    if (view == nil){
        [[NSBundle mainBundle] loadNibNamed:@"AudioView" owner:self options:nil];
    }
    self.view.songLabel.text = @"Transfering...";
    
    if (thumbDownloader.state == TransferableStateTransferred) {
        NSData *thumbData = [NSData dataWithContentsOfFile: [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:thumbDownloader.filename]];
        thumb = [[UIImage imageWithData:thumbData] retain];
    }
    
    if (self.song != nil && (thumb == nil || thumbDownloader.state == TransferableStateTransferred)) {
        [self createThumb];
    }
    
    if (thumb != nil) {
        self.view.coverImage.image = self.thumb;
        if (song != nil){
            self.view.songLabel.text = [NSString stringWithFormat:@"%@ - %@",[song valueForProperty:MPMediaItemPropertyArtist],[song valueForProperty:MPMediaItemPropertyTitle]];
        }
        else {
            self.view.songLabel.text = @"Recieved Song";
        }
    }
}

- (Preview *)desktopItemView { 
    [self updateImage];

    return view;
 }

- (NSString *)defaultFilename {
    
    return @"Song";
}

- (NSString *)extension {
	return @"m4a";
}

- (NSString *)mimeType {
	return @"audio/mp4a-latm";
}    


- (BOOL)isDataReady {
    
    if (self.data != nil && audioFileReady == YES){
        return YES;
    }
    else {
        return NO;
    }
}


- (BOOL)needsWaiting {
	return YES;
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_audio.png"];
}

- (NSDictionary *) dataDesctiption {
	NSDictionary *previewDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"image/jpg", @"type",
                                 [self thumbURL], @"uri" , nil];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:self.mimeType forKey:@"type"];
    NSInteger count = 0;
    
    while ([self.transferer url] == nil && count < 10) {
        count++;
        sleep(0.1);
    }
    
    if ([self.transferer url]) {
        [dict setObject:[[self.transferer url] stringByRemovingQuery] forKey:@"uri"];
    }
    
    [self.transferer.cryptor appendInfoToDictionary:dict];
    [dict setObject:[NSArray arrayWithObject: previewDict] forKey:@"preview"];
    
	return dict;
}



#pragma -
#pragma Thumbnail
- (NSString *)thumbFilename {
	NSString *tmpPath = [self.filename stringByDeletingPathExtension];
    
	return [[NSString stringWithFormat:@"%@_thumb", tmpPath] stringByAppendingPathExtension:@"jpg"];
}


- (void)createThumb {

    if ([song valueForProperty:MPMediaItemPropertyArtwork] != nil){
        thumb = [[[song valueForProperty:MPMediaItemPropertyArtwork]imageWithSize:CGSizeMake(400, 400)]retain];
    }
    else {
        thumb = [UIImage imageNamed:@"audio_leer.png"];
    }
    
        
    NSData *thumbData = UIImageJPEGRepresentation(thumb, 0.2);
	[thumbData writeToFile:  [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:self.thumbFilename] atomically: NO];
}

- (NSString *)thumbURL {
    if (thumbURL) {
        return thumbURL;
    }
    
    return  [thumbUploader.url stringByRemovingQuery];
}

#pragma -
#pragma Hooks
- (void)viewDidLoad {
    NSLog(@"upload song %@", self.filename);
    NSObject <Transferable> *transferable = [[[DelayedFileUploaded alloc] initWithFilename:self.filename] autorelease];
    NSLog(@"cryptor %@", self.cryptor);
    transferable.cryptor = self.cryptor;
    [transferables addObject: transferable];
    audioFileReady = NO;
    if (self.data) {
        [(DelayedFileUploaded *)transferable setFileReady: YES];
    }
    
    [self createThumb];
    
    NSLog(@"uploading thumb %@",[self thumbFilename]);
    thumbUploader = [[[DelayedFileUploaded alloc] initWithFilename:[self thumbFilename]] autorelease];
    thumbUploader.cryptor = self.cryptor;
    
    [(DelayedFileUploaded *)thumbUploader setFileReady: YES];
    [transferables addObject: thumbUploader];
}

- (void) dealloc {
	[song release];
    [recievedSong release];
    [view release];
	[thumb release];
    [thumbURL release];
	[super dealloc];
}


@end