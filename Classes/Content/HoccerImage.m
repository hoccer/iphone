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

@interface HoccerImage ()

- (void)createThumb;

@end



@implementation HoccerImage

@synthesize image;
@synthesize thumb;

- (id) initWithFilename:(NSString *)theFilename {
	NSLog(@"%s", _cmd);
	self = [super initWithFilename:theFilename];
	if (self != nil) {
		NSLog(@"image %@", self.image);
		[self createThumb];
	}
	
	return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict {
	NSLog(@"%s", _cmd);
	self = [super initWithDictionary:dict];
	if (self != nil) {
		[self createThumb];
	}
	
	return self;
}


- (id) initWithData:(NSData *)theData {
	NSLog(@"%s", _cmd);
    self = [super initWithData:theData];
	if (self != nil) {
		[self createThumb];
	}
	
	return self;
}

- (id)initWithUIImage: (UIImage *)aImage {
	NSLog(@"%s", _cmd);
	self = [super init];
	if (self != nil) {
		transferable = [[DelayedFileUploaded alloc] initWithFilename:self.filename];
		
		isFromContentSource = YES;
		
		image = [aImage retain];
		[self createThumb];
		
		[self performSelectorInBackground:@selector(createDataRepresentaion:) withObject:self];
	}
	
	return self;
}

- (void)createThumb {
	NSString *ext = [self.filename pathExtension];
	NSString *tmpPath = [self.filename stringByDeletingPathExtension];
	thumbFilename = [[[NSString stringWithFormat:@"%@_thumb", tmpPath] stringByAppendingPathExtension:ext] copy];
	
	CGSize size = CGSizeMake(self.image.size.width / 4, self.image.size.height / 4);
	thumb = [[self.image gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:NO] retain];
}

- (void)createDataRepresentaion: (HoccerImage *)content {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	content.data = UIImageJPEGRepresentation(content.image, 0.8);
	[content saveDataToDocumentDirectory];
	
	NSData *thumbData = UIImageJPEGRepresentation(content.thumb, 0.5);
	[thumbData writeToFile: thumbFilename atomically: NO];
	
	[self performSelectorOnMainThread:@selector(didFinishDataRepresentation) withObject:nil waitUntilDone:YES];
	
	[pool drain];
}

- (void)didFinishDataRepresentation {
	[((DelayedFileUploaded *)transferable) setFileReady:YES];
}

- (UIImage*) image {
	if (image == nil && self.data != nil) {
		image = [[UIImage imageWithData:self.data] retain];
	}
	return image;
} 

- (void) dealloc {
	[image release];
	[preview release];
	[thumb release];
    [thumbFilename release];
    
	[super dealloc];
}

- (UIView *)fullscreenView  {	
	CGSize size = CGSizeMake(320, 480);
	
	UIImage *scaledImage = [self.image gtm_imageByResizingToSize: size
										 preserveAspectRatio: YES
												   trimToFit: YES];

	return [[[UIImageView alloc] initWithImage: scaledImage] autorelease]; 
}

- (void)updateImage {
//	NSInteger paddingLeft = 22;
//	NSInteger paddingTop = 22;
//
//	CGFloat frameWidth = preview.frame.size.width - (2 * paddingLeft); 
//	CGFloat frameHeight = preview.frame.size.height - (2 * paddingTop);
//	
//	CGSize size =  CGSizeMake(frameWidth, frameHeight);
//
//	UIImage *thumb = [self.image gtm_imageByResizingToSize: size preserveAspectRatio:YES
//												 trimToFit: YES];
	
	[preview setImage: thumb];	
}

- (Preview *)desktopItemView {
	if (self.image == nil) {
		return nil;
	}
	
	preview = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 303, 224)];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"container_image-land.png"]];

	[preview addSubview:backgroundImage];
	[preview sendSubviewToBack:backgroundImage];
	[backgroundImage release];

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
	NSDictionary *previewDict = [NSDictionary dictionaryWithObjectsAndKeys:@"image/jpeg", @"type", nil];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:self.mimeType forKey:@"type"];
	[dict setObject:[[self.transferer url] stringByRemovingQuery] forKey:@"uri"];
    [dict setObject:previewDict forKey:@"preview"];
	
    NSLog(@"%@", dict);
	return dict;
}

@end