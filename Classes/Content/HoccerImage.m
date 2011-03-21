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
        NSLog(@"initWithFilename");
        preview = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 303, 224)];

        
        [self createThumb];
        
        thumbUploader = [[[DelayedFileUploaded alloc] initWithFilename:[self thumbFilename]] autorelease];
        [(DelayedFileUploaded *)thumbUploader setFileReady: YES];
        [transferables addObject: thumbUploader];
	}
	
	return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict {
	self = [super initWithDictionary:dict];
	if (self != nil) {
        preview = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 303, 224)];

        NSArray *previews = [dict objectForKey:@"preview"];
        if (previews && [previews count] > 0) {
            thumbURL = [[previews objectAtIndex:0] objectForKey:@"uri"];
            thumbDownloader = [[FileDownloader alloc] initWithURL:thumbURL filename:nil];
            
            [transferables addObject:thumbDownloader];
        }
	}
	
	return self;
}

- (id) initWithData:(NSData *)theData {
    self = [super initWithData:theData];
	if (self != nil) {
		NSLog(@"initWithData");
        [self createThumb];
        
        thumbUploader = [[[DelayedFileUploaded alloc] initWithFilename:[self thumbFilename]] autorelease];
        [transferables addObject: thumbUploader];
	}
	
	return self;
}

- (id)initWithUIImage: (UIImage *)aImage {
	self = [super init];
	if (self != nil) {
		image = [aImage retain];
		isFromContentSource = YES;
		
        preview = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 303, 224)];
        
		NSObject <Transferable> *transferable = [[[DelayedFileUploaded alloc] initWithFilename:self.filename] autorelease];
		[transferables addObject: transferable];

		[self createThumb];
        
        thumbUploader = [[[DelayedFileUploaded alloc] initWithFilename:[self thumbFilename]] autorelease];
        [transferables addObject: thumbUploader];

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
	CGSize size = CGSizeMake(320, 480);
	
	UIImage *scaledImage = [self.image gtm_imageByResizingToSize: size
										 preserveAspectRatio: YES
												   trimToFit: YES];

	return [[[UIImageView alloc] initWithImage: scaledImage] autorelease]; 
}

- (void)updateImage {    
    if (thumbDownloader.state == TransferableStateTransferred) {
        NSData *thumbData = [NSData dataWithContentsOfFile: [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:thumbDownloader.filename]];
        thumb = [[UIImage imageWithData:thumbData] retain];
    }
    
    if (thumb != nil) {
        [preview setImage: thumb];
    } else {
        [preview setImage: self.image];
    }
}

- (Preview *)desktopItemView { 
//	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"container_image-land.png"]];
//
//	[preview addSubview:backgroundImage];
//	[preview sendSubviewToBack:backgroundImage];
//	[backgroundImage release];

	[self updateImage];
	return preview;
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
	[dict setObject:[[self.transferer url] stringByRemovingQuery] forKey:@"uri"];
    [dict setObject:[NSArray arrayWithObject: previewDict] forKey:@"preview"];
    NSLog(@"dict %@", dict);
    
	return dict;
}

#pragma -
#pragma Thumbnail
- (NSString *)thumbFilename {
	NSString *ext = [self.filename pathExtension];
	NSString *tmpPath = [self.filename stringByDeletingPathExtension];
    
	return [[[NSString stringWithFormat:@"%@_thumb", tmpPath] stringByAppendingPathExtension:ext] copy];
}


- (void)createThumb {
    NSInteger paddingLeft = 22;
	NSInteger paddingTop = 22;
    
	CGFloat frameWidth = preview.frame.size.width - (2 * paddingLeft); 
	CGFloat frameHeight = preview.frame.size.height - (2 * paddingTop);
	
	CGSize size =  CGSizeMake(frameWidth, frameHeight);
    
	thumb = [[self.image gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:YES] retain];
    
    NSData *thumbData = UIImageJPEGRepresentation(thumb, 0.1);
	[thumbData writeToFile:  [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:self.thumbFilename] atomically: NO];
}

- (NSString *)thumbURL {
    if (thumbURL) {
        return thumbURL;
    }
    
    return  [thumbUploader.url stringByRemovingQuery];
}

- (void) dealloc {
	[image release];
	[preview release];
	[thumb release];
    
	[super dealloc];
}


@end