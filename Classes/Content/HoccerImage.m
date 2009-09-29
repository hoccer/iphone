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
	}
	return self;
}



- (id)initWithData: (NSData *)data 
{
	self = [super init];
	if (self != nil) {
		image = [[UIImage imageWithData:data] retain];
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
	return [[[UIImageView alloc] initWithImage:image] autorelease]; 
}


-(void) dealloc 
{
	[super dealloc];
	[image release];
}

- (NSString *)saveButtonDescription 
{
	return @"Save to Gallery";
}


@end
