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
	
	NSInteger padding = 15;
	NSInteger width =  self.frame.size.width - (2 * padding);
	
	if (image.size.width < image.size.height) {
		;
	} else {
		;
	}
	
	UIImage *thumb = [image acImageScaledToWidth: width];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(padding, padding, thumb.size.width, thumb.size.height)];
	imageView.image = thumb;
	
	[self addSubview: imageView];
	[imageView release];
}

- (void)drawRect: (CGRect)rect
{
    // [super drawRect:rect];
	NSLog(@"drawing rect");
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	
	CGContextFillRect(context, rect);
}

@end
