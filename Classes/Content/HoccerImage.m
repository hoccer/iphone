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
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)dismiss {}

- (UIView *)view 
{	
	UIImage *scaledImage = [image acImageScaledToWidth: 400];
	return [[[UIImageView alloc] initWithImage: scaledImage] autorelease]; 
}

- (UIView *)preview
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

- (void) dealloc 
{
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

@end