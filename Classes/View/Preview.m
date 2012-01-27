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
@synthesize allowsOverlay;

- (id) initWithFrame: (CGRect) frame {
	self = [super initWithFrame:frame];	
	if (self != nil) {
		self.allowsOverlay = YES;
	}
	return self;
}

-  (void)awakeFromNib {
	self.allowsOverlay = YES;
}

- (void) setImage: (UIImage *)image {
    [imageView removeFromSuperview];
    [imageView release]; imageView = nil;
        
	
    NSInteger paddingLeft = 13;
	NSInteger paddingTop = 13;
	
    
    CGSize size = { .width = 303 - (2*paddingLeft), .height = 224 - (2*paddingTop) };
    image = [image gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:YES];
        
	imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, size.width,size.height)];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = self.center;
	imageView.image = image;
    
  	[self addSubview:imageView];
}


- (void)setBackgroundImage:(UIImage *)aImage {
    [backgroundImage removeFromSuperview];
    [backgroundImage release]; backgroundImage = nil;

    backgroundImage = [[UIImageView alloc] initWithImage:aImage];
    [backgroundImage setContentMode:UIViewContentModeScaleToFill];
    
    [self addSubview:backgroundImage];
    [self sendSubviewToBack:backgroundImage];

}

- (void)setContentIdentifier:(UIImage *)aImage {

    [contentIdentifier removeFromSuperview];
    [contentIdentifier release]; contentIdentifier = nil;
    
    contentIdentifier = [[UIImageView alloc] initWithFrame: CGRectMake(251, 178, 38, 26)];
	contentIdentifier.contentMode = UIViewContentModeScaleAspectFit;
    contentIdentifier.image = aImage;
    
    [self addSubview:contentIdentifier];
}

- (void)dealloc {
    [imageView release];
    [super dealloc];
}

@end
