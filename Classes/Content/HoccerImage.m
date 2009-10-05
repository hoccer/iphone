//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerImage.h"
#import "ACResizeImage.h"


@implementation HoccerImage

- (id)initWithUIImage: (UIImage *)aImage
{
	self = [super init];
	if (self != nil) {
		isDataReady = NO;
		
		image = [aImage retain];
		secondThread = [[NSThread alloc] 
						initWithTarget:self selector:@selector(createDataRepresentaion) 
												 object:nil];	
		[secondThread start];
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
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)dismiss {}

- (UIView *)view 
{	
	UIImage *scaledImage = [image acImageScaledToWidth: 400];
	return [[[UIImageView alloc] initWithImage: scaledImage] autorelease]; 
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
	NSLog(@"canceling thread");
	[secondThread cancel];
	[secondThread release];
	
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
	return isDataReady;
}

- (void)createDataRepresentaion
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"creating jpeg representation");
	data = UIImageJPEGRepresentation(image, 1.0);

	if (![[NSThread currentThread] isCancelled]) {
		[data retain];
		isDataReady = YES;
		NSLog(@"finished jpeg represenation");
	}

	[pool drain];
}	
	

@end
