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
	
    NSInteger paddingLeft = 22;
	NSInteger paddingTop = 22;
	
    CGSize size = { .width = 303 - 44, .height = 224 - 44 };
    image = [image gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:YES];
    
	imageView = [[UIImageView alloc] initWithFrame: CGRectMake(paddingLeft, paddingTop, image.size.width, image.size.height)];
	imageView.contentMode = UIViewContentModeCenter;
	imageView.image = image;
	
	[self insertSubview:imageView atIndex:1];
}

- (void) setAudioImage: (UIImage *)image {
    [imageView removeFromSuperview];
    [imageView release]; imageView = nil;
	
    NSInteger paddingLeft = 30;
	NSInteger paddingTop = 6;
	
    CGSize size = { .width = 200, .height = 200 };
    image = [image gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:YES];
    
	imageView = [[UIImageView alloc] initWithFrame: CGRectMake(paddingLeft, paddingTop, image.size.width, image.size.height)];
	imageView.contentMode = UIViewContentModeCenter;
	imageView.image = image;
    [self insertSubview:imageView atIndex:1];

}

- (void) setVideoImage: (UIImage *)image {
    [imageView removeFromSuperview];
    [imageView release]; imageView = nil;
	
    NSInteger paddingLeft = 27;
	NSInteger paddingTop = 24;
	
    CGSize size = { .width = 210, .height = 160 };
    image = [image gtm_imageByResizingToSize:size preserveAspectRatio:YES trimToFit:YES];
    
	imageView = [[UIImageView alloc] initWithFrame: CGRectMake(paddingLeft, paddingTop, image.size.width, image.size.height)];
	imageView.contentMode = UIViewContentModeCenter;
	imageView.image = image;
    [self insertSubview:imageView atIndex:1];
    
}
- (void)dealloc {
    [imageView release];
    [super dealloc];
}

@end
