//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerImage.h"
#import "ACResizeImage.h"
#import "PreviewView.h"

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
	
	NSLog(@"creating jpeg representation");
	content.data = UIImageJPEGRepresentation(content.image, 0.8);
	
	if (![[NSThread currentThread] isCancelled]) {
		self.isReady = YES;
		NSLog(@"finished jpeg represenation");
	}
	
	[pool drain];
}	

@end


@implementation HoccerImage

@synthesize data;
@synthesize image;

- (id)initWithUIImage: (UIImage *)aImage
{
	self = [super init];
	if (self != nil) {
		image = [aImage retain];
		isDataReady = NO;
		
		MyThreadClass *threadClass = [[[MyThreadClass alloc] init] autorelease];
		[NSThread detachNewThreadSelector:@selector(createDataRepresentaion:)
								 toTarget:threadClass withObject:self];
	}
	
	return self;
}


- (id)initWithData: (NSData *)aData 
{
	self = [super init];
	if (self != nil) {
		data = [aData retain];
		image = [[UIImage imageWithData:aData] retain];
	}
	return self;
}

- (void)save
{
	NSLog(@"saving image");
	UIImageWriteToSavedPhotosAlbum(image, self,  @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)dismiss {}

- (UIView *)view 
{	
	CGSize size = CGSizeMake(320, 480);
	
	UIImage *scaledImage = [image gtm_imageByResizingToSize: size
										 preserveAspectRatio: YES
												   trimToFit: YES];

	return [[[UIImageView alloc] initWithImage: scaledImage] autorelease]; 
}

- (PreviewView *)preview
{
	PreviewView *view = [[PreviewView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
	
	[view setImage:image];
	return [view autorelease];
}

- (NSString *)filename
{
	return @"test.jpg";
}

- (NSString *)mimeType
{
	return @"image/jpeg";
}

- (NSData *)data
{
	return data;
}

- (void)dealloc 
{
	NSLog(@"deallocation image");
	[image release];
	[data release];
	
	[super dealloc];
}

- (NSString *)saveButtonDescription 
{
	return @"Save to Gallery";
}

- (BOOL)isDataReady
{
	return (data != nil);
}

- (void)contentWillBeDismissed
{
}

-(void) image: (UIImage *)aImage  didFinishSavingWithError: (NSError *) error 
				contextInfo: (void *) contextInfo 
{
	NSLog(@"saved %@, error: %@", aImage, error);
	
	[target checkAndPerformSelector: selector];
}

- (BOOL)needsWaiting
{
	return YES;
}

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector 
{
	target = aTarget;
	selector  = aSelector;
}

@end