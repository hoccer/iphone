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
	NSInteger paddingLeft = 22;
	NSInteger paddingTop = 22;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(paddingLeft, paddingTop, image.size.width, image.size.height)];
	imageView.contentMode = UIViewContentModeCenter;
	imageView.image = image;
	
	[self insertSubview:imageView atIndex:1];
	[imageView release];
}

@end
