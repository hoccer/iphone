//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
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

@interface HoccerMusic ()

- (void)createThumb;

@end

@implementation HoccerMusic
@synthesize song,receivedSong;
@synthesize thumb;
@synthesize view,fullscreenPlayer;

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
                thumbDownloader = [[FileDownloader alloc] initWithURL:thumbURL filename: self.thumbFilename];
                thumbDownloader.cryptor = self.cryptor;
            
                [transferables addObject:thumbDownloader];
            }
        }
        canBeCiphered = NO;
	}
	return self;
}

- (id)initWithMediaItem: (MPMediaItem *)aMediaItem{
	self = [super init];
	if (self != nil) {
		song = [aMediaItem retain];
		isFromContentSource = YES;
		canBeCiphered = YES;
        
        NSString * newName = [NSString stringWithFormat:@"%@ - %@",[song valueForProperty:MPMediaItemPropertyArtist],[song valueForProperty:MPMediaItemPropertyTitle]];
        newName = [[[NSFileManager defaultManager] sanitizeFileNameString:newName] stringByAppendingPathExtension: [self extension]];
        [self setFilename:newName];
        // NSLog(@"newName = %@", newName);
        // NSLog(@"self.filename = %@", self.filename);
        // NSLog(@"filename = %@", filename);
        
		[self performSelectorInBackground:@selector(createDataRepresentation:) withObject:self];
	}
	
	return self;
}

- (void)createDataRepresentation: (HoccerMusic *)content {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURL *assetURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
 
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: songAsset
                                      presetName: AVAssetExportPresetAppleM4A];
    
    NSString *exportFile = [[[NSFileManager defaultManager]contentDirectory] stringByAppendingPathComponent: [[NSFileManager defaultManager]uniqueFilenameForFilename: self.filename inDirectory:[[NSFileManager defaultManager]contentDirectory]]];
    
    
    NSLog(@"exportFile = %@", exportFile);
    
    exporter.outputURL = [[NSURL fileURLWithPath:exportFile] retain];
    exporter.outputFileType = AVFileTypeAppleM4A;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                // log error to text view
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"ErrorMessage_LoadingSongFailed", nil) forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"Song failed" code:796 userInfo:userInfo];
                [self audioExporterFailed:error];
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                //NSLog (@"AVAssetExportSessionStatusCompleted");
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
    // NSLog(@"updateImage");
    if (view == nil){
        [[NSBundle mainBundle] loadNibNamed:@"AudioView" owner:self options:nil];
    }
    self.view.songLabel.text = NSLocalizedString(@"Title_UntitledSong", nil);
    
    if (thumbDownloader.state == TransferableStateTransferred) {
        // NSLog(@"updateImage 2");
        NSData *thumbData = [NSData dataWithContentsOfFile: [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:thumbDownloader.filename]];
        thumb = [[UIImage imageWithData:thumbData] retain];
    }
    
    if (self.song != nil && (thumb == nil || thumbDownloader.state == TransferableStateTransferred)) {
        // NSLog(@"updateImage 3");
        [self createThumb];
    }
    // NSLog(@"updateImage: thumb=%@", thumb);
    
    if (thumb != nil) {
        // NSLog(@"updateImage 4");
        self.view.coverImage.image = [self.thumb retain];
        if (song != nil){
            // NSLog(@"updateImage 4a");
            self.view.songLabel.text = [NSString stringWithFormat:@"%@ - %@",[song valueForProperty:MPMediaItemPropertyArtist],[song valueForProperty:MPMediaItemPropertyTitle]];
        }
        else {
            // NSLog(@"updateImage 4b");
            self.view.songLabel.text = self.filename;
        }
    }
}

- (Preview *)desktopItemView { 
    [self updateImage];

    return view;
 }

- (NSString *)defaultFilename {
    
    return NSLocalizedString(@"DefaultFilename_Music", nil);
}

- (NSString *)extension {
	return @"m4a";
}

- (NSString *)mimeType {
	return @"audio/mp4";
}    


- (BOOL)isDataReady {
    
    if (self.data != nil && audioFileReady == YES){
        return YES;
    }
    else {
        return NO;
    }
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

    
    NSString *crypted = [self.transferer.cryptor encryptString:self.filename];
    NSLog(@"filename = %@, crypted = %@", self.filename, crypted);
    [dict setObject:crypted forKey:@"filename"];
    
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

    NSLog(@"dataDesctiption = %@", dict);
    
	return dict;
}


- (UIView *)fullscreenView
{
    CGRect screenRect;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        screenRect = [[UIScreen mainScreen] bounds];
        screenRect.size.height = screenRect.size.height - (20+44+48);
    }
    else {
        screenRect = CGRectMake(0, 0, 320, 367);
    }
    
    self.fullscreenPlayer =[[MPMoviePlayerController alloc] initWithContentURL: self.fileUrl];
    self.fullscreenPlayer.view.frame = screenRect;
    
    self.fullscreenPlayer.controlStyle = MPMovieControlStyleDefault;
    //self.fullscreenPlayer.shouldAutoplay = NO;
    
    [self.fullscreenPlayer prepareToPlay];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pausePlayer)
                                                 name:@"PausePlayer"
                                               object:nil];
    return self.fullscreenPlayer.view;
}

- (UIView *)smallView
{
    CGRect screenRect;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        screenRect = CGRectMake(15, 15, 272, 32);
    }
    else {
        screenRect = CGRectMake(15, 15, 272, 32);
    }
   
    self.fullscreenPlayer =[[MPMoviePlayerController alloc] initWithContentURL:self.fileUrl];
    self.fullscreenPlayer.view.frame = screenRect;
    
    self.fullscreenPlayer.controlStyle = MPMovieControlStyleDefault;
    //self.fullscreenPlayer.shouldAutoplay = YES;
    
    [self.fullscreenPlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pausePlayer2)
                                                 name:@"PausePlayer2"
                                               object:nil];
    return self.fullscreenPlayer.view;
}

#pragma -
#pragma Thumbnail
- (NSString *)thumbFilename {
	NSString *tmpPath = [self.filename stringByDeletingPathExtension];
    
	return [[NSString stringWithFormat:@"%@_thumb", tmpPath] stringByAppendingPathExtension:@"jpg"];
}

- (void)createThumb {
    
    MPMediaItemArtwork * artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    // NSLog(@"createThumb1: artwork=%@", artwork);
    UIImage * artworkImage = [artwork imageWithSize:CGSizeMake(400,400)];
    
    if (artworkImage != nil){
        thumb = artworkImage;
        // NSLog(@"createThumb1: thumb=%@", thumb);
    }
    else {
        thumb = [UIImage imageNamed:@"audio_leer.png"];
        // NSLog(@"createThumb2: thumb=%@", thumb);
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

- (void)pausePlayer {
    [self.fullscreenPlayer pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)pausePlayer2 {
    [self.fullscreenPlayer pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)playPlayer {
//    [self.fullscreenPlayer play];
//}

#pragma -
#pragma Hooks
- (void)viewDidLoad {
    //NSLog(@"upload song %@", self.filename);
    NSObject <Transferable> *transferable = [[[DelayedFileUploaded alloc] initWithFilename:self.filename] autorelease];
    //NSLog(@"cryptor %@", self.cryptor);
    transferable.cryptor = self.cryptor;
    [transferables addObject: transferable];
    audioFileReady = NO;
    
    // if (self.data) {
    //    [(DelayedFileUploaded *)transferable setFileReady: YES];
    // }
    
    [self createThumb];
    
    //NSLog(@"uploading thumb %@",[self thumbFilename]);
    thumbUploader = [[[DelayedFileUploaded alloc] initWithFilename:[self thumbFilename]] autorelease];
    thumbUploader.cryptor = self.cryptor;
    
    [(DelayedFileUploaded *)thumbUploader setFileReady: YES];
    [transferables addObject: thumbUploader];
}

- (void) dealloc {
	[song release];
    [receivedSong release];
    [view release];
	[thumb release];
    [thumbURL release];
    [fullscreenPlayer release];
	[super dealloc];
}


@end