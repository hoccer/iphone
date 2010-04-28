//
//  PreviewView.m
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "Preview.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

@implementation Preview

- (id) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame:frame];	
	if (self != nil) {

	}
	return self;
}

- (void) setImage: (UIImage *)image
{
	NSInteger paddingLeft = 22;
	NSInteger paddingTop = 22;
	
	CGFloat frameWidth = self.frame.size.width - (2 * paddingLeft); 
	CGFloat frameHeight = self.frame.size.height - (2 * paddingTop);
		
	CGSize size =  CGSizeMake(frameWidth, frameHeight);
	UIImage *thumb = [image gtm_imageByResizingToSize: size preserveAspectRatio:YES
										trimToFit: YES];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(paddingLeft, paddingTop, size.width, size.height)];
	imageView.image = thumb;
	
	[self insertSubview:imageView atIndex:1];
	[imageView release];
}



@end
