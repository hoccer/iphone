//
//  HoccerImage.m
//  Hoccer
//
//  Created by Robert Palmer on 09.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerImage.h"


@implementation HoccerImage

- (id)initWithUIImage: (UIImage *)aImage
{
	self = [super init];
	if (self != nil) {
		image = [aImage retain];
		data = 	UIImageJPEGRepresentation(image, 1.0);
		[data retain];
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

- (void)saveWithSelector: (SEL)selector target: (id)target
{
	NSLog(@"image: %@", image);
	//UIImageWriteToSavedPhotosAlbum(image, target, selector, nil);
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)dismiss {}

- (UIView *)view 
{
	return [[[UIImageView alloc] initWithImage:image] autorelease]; 
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


-(void) dealloc 
{
	[image release];
	[data release];
	
	[super dealloc];
}

- (NSString *)saveButtonDescription 
{
	return @"Save to Gallery";
}


@end
