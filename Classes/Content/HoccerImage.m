//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerImage.h"
#import "NSString+URLHelper.h"
#import "Hoccer.h"
#import "Preview.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

#import "FileDownloader.h"
#import "DelayedFileUploaded.h"

#import "NSFileManager+FileHelper.h"

@interface HoccerImage ()

- (void)createThumb;

@end

@implementation HoccerImage
@synthesize image;
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
        }
        canBeCiphered = NO;
	}
	
	return self;
}

- (id)initWithUIImage: (UIImage *)aImage {
	self = [super init];
	if (self != nil) {
		image = [aImage retain];
		isFromContentSource = YES;
        canBeCiphered = YES;
		
		[self performSelectorInBackground:@selector(createDataRepresentaion:) withObject:self];
	}
	
	return self;
}

- (void)createDataRepresentaion: (HoccerImage *)content {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	content.data = UIImageJPEGRepresentation(content.image, 0.8);
	[content saveDataToDocumentDirectory];
	    
	[self performSelectorOnMainThread:@selector(didFinishDataRepresentation) withObject:nil waitUntilDone:YES];
	
	[pool drain];
}

- (void)didFinishDataRepresentation {
    for (DelayedFileUploaded *transferable in transferables) {
       [transferable setFileReady:YES];
    }
}

- (UIImage*) image {
	if (image == nil && self.data != nil) {
		image = [[UIImage imageWithData:self.data] retain];
	}
	return image;
} 

- (UIView *)fullscreenView  {	
    fullScreenImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 367)];
    fullScreenImage.image = self.image;
	fullScreenImage.contentMode = UIViewContentModeScaleAspectFit;
    UIScrollView *theScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,367)];
    theScrollView.contentSize = self.image.size;
    theScrollView.delegate = self;
    theScrollView.maximumZoomScale = 4.0;
    theScrollView.minimumZoomScale = 1.0;
    theScrollView.decelerationRate = .85;
	theScrollView.contentSize = CGSizeMake(320,367);
    theScrollView.bouncesZoom = YES;
    theScrollView.autoresizesSubviews = YES;
    theScrollView.contentMode = (UIViewContentModeCenter);
    theScrollView.multipleTouchEnabled = YES;
    theScrollView.userInteractionEnabled = YES;
    theScrollView.backgroundColor = [UIColor blackColor];
    [theScrollView addSubview:fullScreenImage];
    return theScrollView;
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{

    return fullScreenImage;
    
}

- (void)updateImage {    
    if (thumbDownloader.state == TransferableStateTransferred) {
        NSData *thumbData = [NSData dataWithContentsOfFile: [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:thumbDownloader.filename]];
        thumb = [[UIImage imageWithData:thumbData] retain];
    }
    
    if (self.image != nil && (thumb == nil || thumbDownloader.state == TransferableStateTransferred)) {
        [self createThumb];
    }
    
    if (thumb != nil) {
        [self.preview setImage: thumb];
    }
}

- (Preview *)desktopItemView { 
	[self updateImage];
    
	return self.preview;
}

- (NSString *)defaultFilename {
	return @"Image";
}

- (NSString *)extension {
	return @"jpg";
}

- (NSString *)mimeType {
	return @"image/jpeg";
}    

- (NSString *)descriptionOfSaveButton {
	return NSLocalizedString(@"Save", nil);
}

- (BOOL)isDataReady {
	return (self.data != nil);
}

- (BOOL)saveDataToContentStorage {
	UIImageWriteToSavedPhotosAlbum(self.image, self,  @selector(image:didFinishSavingWithError:contextInfo:), nil);
	return YES;
}

-(void) image: (UIImage *)aImage didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
	[self sendSaveSuccessEvent];
}

- (UIImage *)imageForSaveButton {
	return [UIImage imageNamed:@"container_btn_double-save.png"];
}

- (BOOL)needsWaiting {
	return YES;
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_image.png"];
}

- (NSDictionary *) dataDesctiption {
	NSDictionary *previewDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    @"image/jpeg", @"type",
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
	NSString *ext = [self.filename pathExtension];
	NSString *tmpPath = [self.filename stringByDeletingPathExtension];
    
	return [[NSString stringWithFormat:@"%@_thumb", tmpPath] stringByAppendingPathExtension:ext];
}


- (void)createThumb {
    NSInteger paddingLeft = 4;
	NSInteger paddingTop = 4;
    
	CGFloat frameWidth = self.preview.frame.size.width - (2 * paddingLeft); 
	CGFloat frameHeight = self.preview.frame.size.height - (2 * paddingTop);
	
	CGSize size = CGSizeMake(frameWidth, frameHeight);
    
	thumb = [[self.image gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:YES] retain];
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
        preview = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 303, 224)];
        [preview setBackgroundImage:[UIImage imageNamed:@"content_bg_image"]];

    }
    
    return preview;
}

#pragma -
#pragma Hooks
- (void)viewDidLoad {
    NSLog(@"upload image %@", self.filename);
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
	[image release];
	[preview release];
	[thumb release];
    [thumbURL release];
    
	[super dealloc];
}


@end