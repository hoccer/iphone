//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerImage.h"
#import "Preview.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

@interface MyThreadClass : NSObject
{
	BOOL isReady;
}

@property (assign) BOOL isReady;

- (void)createDataRepresentaion: (HoccerImage *)content;
@end

@implementation MyThreadClass
@synthesize isReady;

- (void)createDataRepresentaion: (HoccerImage *)content
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	content.data = UIImageJPEGRepresentation(content.image, 0.8);
	[content saveDataToDocumentDirectory];
	
	if (![[NSThread currentThread] isCancelled]) {
		self.isReady = YES;
	}
	
	[pool drain];
}	

@end


@implementation HoccerImage

@synthesize image;

- (id)initWithUIImage: (UIImage *)aImage
{
	self = [super init];
	if (self != nil) {
		image = [aImage retain];
		
		MyThreadClass *threadClass = [[[MyThreadClass alloc] init] autorelease];
		[NSThread detachNewThreadSelector:@selector(createDataRepresentaion:)
								 toTarget:threadClass withObject:self];
	}
	
	return self;
}

- (UIImage*) image {
	if (image == nil && data != nil) {
		image = [[UIImage imageWithData:data] retain];
	}
	return image;
} 

- (void) dealloc {
	[image release];
	[super dealloc];
}

- (UIView *)fullscreenView 
{	
	CGSize size = CGSizeMake(320, 480);
	
	UIImage *scaledImage = [image gtm_imageByResizingToSize: size
										 preserveAspectRatio: YES
												   trimToFit: YES];

	return [[[UIImageView alloc] initWithImage: scaledImage] autorelease]; 
}

- (Preview *)desktopItemView {
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 319, 234)];
	
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Photobox" ofType:@"png"];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImagePath]];

	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	[backgroundImage release];

	[view setImage: self.image];
	return [view autorelease];
}
	

- (NSString *)extension {
	return @"jpg";
}

- (NSString *)mimeType {
	return @"image/jpeg";
}

- (NSString *)descriptionOfSaveButton {
	return @"Save to Gallery";
}

- (BOOL)isDataReady
{
	return (data != nil);
}

- (void)saveDataToContentStorage
{
	UIImageWriteToSavedPhotosAlbum(image, self,  @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

-(void) image: (UIImage *)aImage  didFinishSavingWithError: (NSError *) error 
				contextInfo: (void *) contextInfo {
	[target checkAndPerformSelector: selector];
}

- (BOOL)needsWaiting {
	return YES;
}

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector {
	target = aTarget;
	selector  = aSelector;
}

@end