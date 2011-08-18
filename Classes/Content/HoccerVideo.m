//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerVideo.h"
#import "NSString+URLHelper.h"
#import "Hoccer.h"
#import "Preview.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

#import "FileDownloader.h"
#import "DelayedFileUploaded.h"

#import "NSFileManager+FileHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface HoccerVideo ()

- (void)createThumb;

@end

@implementation HoccerVideo
@synthesize videoURL;
@synthesize thumb;

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
    
    if (self.videoURL != nil && (thumb == nil || thumbDownloader.state == TransferableStateTransferred)) {
        [self createThumb];
    }
    
    if (thumb != nil) {
        [self.preview setVideoImage: thumb];
    }
}

- (Preview *)desktopItemView { 
	[self updateImage];
    
	return self.preview;
}

- (UIView *)fullscreenView {

    MPMoviePlayerController *player =[[MPMoviePlayerController alloc] initWithContentURL: self.fileUrl];
    player.view.frame = CGRectMake(0, 0, 320, 367);
    
    player.controlStyle = MPMovieControlStyleDefault;  
    player.shouldAutoplay = NO;  
    
    return player.view;
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
    
    MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] 
                                   initWithContentURL:videoURL];
    mp.shouldAutoplay = NO;
    mp.initialPlaybackTime = 0.1;
    mp.currentPlaybackTime = 0.1;
    // get the thumbnail
    UIImage *thumbnail = [mp thumbnailImageAtTime:0.1 
                                       timeOption:MPMovieTimeOptionNearestKeyFrame];
    // clean up the movie player
    [mp stop];
    [mp release];
    thumb = [[thumbnail gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:YES] retain];
    NSData *thumbData = UIImageJPEGRepresentation(thumb, 0.2);
	[thumbData writeToFile:  [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:self.thumbFilename] atomically: NO];
}

- (NSString *)thumbURL {
    if (thumbURL) {
        return thumbURL;
    }
    
    return  [thumbUploader.url stringByRemovingQuery];
}

- (Preview *)preview {
    if (preview == nil) {
        preview = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 263, 212)];
        UIImageView *frontImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_frame.png"]];
        UIView *backgroundView = [[UIView alloc] init];
        preview.backgroundColor = [UIColor clearColor];
        [preview addSubview:backgroundView];
        [preview sendSubviewToBack:backgroundView];
        [preview insertSubview:frontImage atIndex:2];
        [frontImage release];
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
    
	[super dealloc];
}


@end