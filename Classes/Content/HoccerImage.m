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
		// NSLog(@"image: %d", aImage.)
		image = [aImage retain];
		
		MyThreadClass *threadClass = [[[MyThreadClass alloc] init] autorelease];
		[NSThread detachNewThreadSelector:@selector(createDataRepresentaion:)
								 toTarget:threadClass withObject:self];
		
		isFromContentSource = YES;
	}
	
	return self;
}

- (UIImage*) image {
	if (image == nil && self.data != nil) {
		image = [[UIImage imageWithData:self.data] retain];
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
	
	UIImage *scaledImage = [self.image gtm_imageByResizingToSize: size
										 preserveAspectRatio: YES
												   trimToFit: YES];

	return [[[UIImageView alloc] initWithImage: scaledImage] autorelease]; 
}

- (Preview *)desktopItemView {
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 303, 224)];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"container_image-land.png"]];

	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	[backgroundImage release];

	
	NSInteger paddingLeft = 22;
	NSInteger paddingTop = 22;
	
	CGFloat frameWidth = view.frame.size.width - (2 * paddingLeft); 
	CGFloat frameHeight = view.frame.size.height - (2 * paddingTop);
	
	CGSize size =  CGSizeMake(frameWidth, frameHeight);
	UIImage *thumb = [self.image gtm_imageByResizingToSize: size preserveAspectRatio:YES
											trimToFit: YES];
	
	[view setImage: thumb];
	return [view autorelease];
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

- (void)saveDataToContentStorage
{
	UIImageWriteToSavedPhotosAlbum(self.image, self,  @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

-(void) image: (UIImage *)aImage  didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
	if ([target respondsToSelector:selector]) {
		[target performSelector:selector withObject:context];
	}
}

- (BOOL)needsWaiting {
	return YES;
}

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector context: (id)aContext {
	target = aTarget;
	selector  = aSelector;
	
	[aContext retain];
	[context release];
	context = aContext;
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_image.png"];
}

@end