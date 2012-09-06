//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "HoccerVideo.h"
#import "NSString+URLHelper.h"
#import "Hoccer.h"
#import "Preview.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

#import "FileDownloader.h"
#import "DelayedFileUploaded.h"

#import "NSFileManager+FileHelper.h"

@interface HoccerVideo ()

- (void)createThumb;

@end

@implementation HoccerVideo
@synthesize videoURL;
@synthesize thumb;
@synthesize fullscreenPlayer;

- (id) initWithFilename:(NSString *)theFilename {
	self = [super initWithFilename:theFilename];
	if (self != nil) {
        canBeCiphered = YES;
	}
	
	return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict {
	self = [super initWithDictionary:dict];
	if (self != nil) {        
        NSArray *previews = [dict objectForKey:@"preview"];
        if (previews && [previews count] > 0) {
            if ([[previews objectAtIndex:0] objectForKey:@"uri"]){
                thumbURL = [[[previews objectAtIndex:0] objectForKey:@"uri"] copy];
                thumbDownloader = [[FileDownloader alloc] initWithURL:thumbURL filename:nil];
                thumbDownloader.cryptor = self.cryptor;
            
                [transferables addObject:thumbDownloader];
            }
            canBeCiphered = NO;
        }
        else {
            thumb = [UIImage imageNamed:@"container_overlay"];
        }
	}
	
	return self;
}

- (id)initWithURL: (NSURL *)aURL {
	self = [super init];
	if (self != nil) {
		videoURL = [aURL retain];
		isFromContentSource = YES;
		canBeCiphered = YES;
		[self performSelectorInBackground:@selector(createDataRepresentaion:) withObject:self];
	}
	
	return self;
}

- (void)createDataRepresentaion: (HoccerVideo *)content {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	content.data = [NSData dataWithContentsOfURL:content.videoURL];
	[content saveDataToDocumentDirectory];
    
	[self performSelectorOnMainThread:@selector(didFinishDataRepresentation) withObject:nil waitUntilDone:YES];
	
	[pool drain];
}

- (void)didFinishDataRepresentation {
    for (DelayedFileUploaded *transferable in transferables) {
        [transferable setFileReady:YES];
    }
}

- (void)updateImage {    
    if (thumbDownloader.state == TransferableStateTransferred) {
        NSData *thumbData = [NSData dataWithContentsOfFile: [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:thumbDownloader.filename]];
        thumb = [[UIImage imageWithData:thumbData] retain];
    }
    
    if (thumb != nil) {
        [self.preview setImage: thumb];
    }
}

- (Preview *)desktopItemView { 
	[self updateImage];
    
	return self.preview;
}

- (UIView *)fullscreenView {
    
        
    self.fullscreenPlayer =[[MPMoviePlayerViewController alloc] initWithContentURL: self.fileUrl];
    self.fullscreenPlayer.view.frame = CGRectMake(0, 0, 320, 367);
    
    self.fullscreenPlayer.moviePlayer.controlStyle = MPMovieControlStyleDefault;  
    self.fullscreenPlayer.moviePlayer.shouldAutoplay = NO;  
    [self.fullscreenPlayer.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    self.fullscreenPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.fullscreenPlayer.moviePlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(pausePlayer) 
                                                 name:@"PausePlayer" 
                                               object:nil];
    
    return self.fullscreenPlayer.view;
}

- (void)pausePlayer {
    [self.fullscreenPlayer.moviePlayer stop];
    [self.fullscreenPlayer release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (NSString *)defaultFilename {
	return @"Video";
}

- (NSString *)extension {
	return @"mov";
}

- (NSString *)mimeType {
	return @"video/quicktime";
}    

- (NSString *)descriptionOfSaveButton {
	return NSLocalizedString(@"Save", nil);
}

- (BOOL)isDataReady {
	return (self.data != nil);
}

- (BOOL)saveDataToContentStorage {
   
    if ( UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.filepath))
    {
        UISaveVideoAtPathToSavedPhotosAlbum(self.filepath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    return YES;

}

-(void) video: (NSString *)videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
	[self sendSaveSuccessEvent];
}

- (UIImage *)imageForSaveButton {
	return [UIImage imageNamed:@"container_btn_double-save.png"];
}

- (BOOL)needsWaiting {
	return YES;
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_video.png"];
}

- (NSDictionary *) dataDesctiption {
	NSDictionary *previewDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"video/quicktime", @"type",
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
    NSInteger paddingLeft = 24;
	NSInteger paddingTop = 24;
    
	CGFloat frameWidth = self.preview.frame.size.width - (2 * paddingLeft); 
	CGFloat frameHeight = self.preview.frame.size.height - (2 * paddingTop);
    
	CGSize size = CGSizeMake(frameWidth, frameHeight);
    
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:self.fileUrl options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    [asset release];
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbnail=[[UIImage imageWithCGImage:im] retain];
            thumb = [[thumbnail gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:NO] retain];
            
            NSData *thumbData = UIImageJPEGRepresentation(thumb, 0.2);
            
            [thumbData writeToFile:  [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:self.thumbFilename] atomically: NO];
            [generator release];
            [self.preview setImage: thumb];   
        }
        else {
            UIImage *thumbnail=[[UIImage imageNamed:@"video_dummy"] retain];
            thumb = [[thumbnail gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:NO] retain];
        
            NSData *thumbData = UIImageJPEGRepresentation(thumb, 0.2);
        
            [thumbData writeToFile:  [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:self.thumbFilename] atomically: NO];
            [generator release];
            [self.preview setImage: thumb];
        }
    };
    
    CGSize maxSize = CGSizeMake(320, 180);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];    
    

}

- (NSString *)thumbURL {
    if (thumbURL) {
        return thumbURL;
    }
    
    return  [thumbUploader.url stringByRemovingQuery];
}

- (Preview *)preview {
    if (preview == nil) {
        preview = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 303, 224)];
        [preview setBackgroundImage:[UIImage imageNamed:@"container_image-land.png"]];
        [preview setContentIdentifier:[UIImage imageNamed:@"video_icon"]];

    }
    
    return preview;
}



#pragma -
#pragma Hooks
- (void)viewDidLoad {
    NSLog(@"upload video %@", self.filename);
    NSObject <Transferable> *transferable = [[[DelayedFileUploaded alloc] initWithFilename:self.filename] autorelease];
    NSLog(@"cryptor %@", self.cryptor);
    transferable.cryptor = self.cryptor;
    [transferables addObject: transferable];
    
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
	[videoURL release];
	[preview release];
	[thumb release];
    [thumbURL release];
    [fullscreenPlayer release];
    
	[super dealloc];
}


@end