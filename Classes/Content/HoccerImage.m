//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerImage.h"
#import "Hoccer.h"
#import "Preview.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

#import "FileDownloader.h"
#import "DelayedFileUploaded.h"

@implementation HoccerImage

@synthesize image;

- (id)initWithUIImage: (UIImage *)aImage {
	self = [super init];
	if (self != nil) {
		transferable = [[DelayedFileUploaded alloc] initWithFilename:self.filename];
		
		image = [aImage retain];
		[self performSelectorInBackground:@selector(createDataRepresentaion:) withObject:self];		
		isFromContentSource = YES;
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
	NSInteger paddingLeft = 22;
	NSInteger paddingTop = 22;

	CGFloat frameWidth = preview.frame.size.width - (2 * paddingLeft); 
	CGFloat frameHeight = preview.frame.size.height - (2 * paddingTop);
	
	CGSize size =  CGSizeMake(frameWidth, frameHeight);

	UIImage *thumb = [self.image gtm_imageByResizingToSize: size preserveAspectRatio:YES
												 trimToFit: YES];
	
	[preview setImage: thumb];	
}

- (Preview *)desktopItemView {
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

@end