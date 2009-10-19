//
//  PreviewView.m
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "PreviewView.h"
#import "ACResizeImage.h"


@implementation PreviewView

- (void) setImage: (UIImage *)image
{
	UIImage *thumb = nil;
	if (image.size.width < image.size.height) {
		thumb = [image acImageScaledToWidth: self.frame.size.width];
	} else {
		thumb = [image acImageScaledToWidth: self.frame.size.width];
	}
	
	[self addSubview:[[[UIImageView alloc] initWithImage:thumb] autorelease]];
}

- (void)drawRect: (CGRect)rect
{
    [super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
	
	CGContextFillRect(context, rect);
}

@end
