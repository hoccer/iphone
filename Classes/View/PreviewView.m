//
//  PreviewView.m
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "PreviewView.h"
#import "ACResizeImage.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

@implementation PreviewView
@synthesize delegate;


- (id) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
		UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button setTitle: @"Dismiss" forState:UIControlStateNormal];
		[button setFrame: CGRectMake(frame.size.width - 60, frame.size.height - 40, 60, 40)];
		[button addTarget: self action: @selector(userDismissedContent:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview: button];
	}
	return self;
}

- (void) setImage: (UIImage *)image
{
	NSInteger padding = 15;
	
	CGFloat frameWidth = self.frame.size.width - (2 * padding);
	CGFloat frameHeight = self.frame.size.height - (2 * padding);
	
	NSInteger thumbWidth = 0;

	CGFloat imageRatio = image.size.height / image.size.width;
	CGFloat frameRatio = frameHeight / frameWidth;
		
	if (imageRatio > frameRatio) {
		thumbWidth = frameHeight / imageRatio;
	} else {
		thumbWidth = frameWidth;
	}
		
	// UIImage *thumb = [image acImageScaledToWidth: thumbWidth];
	
	CGSize size =  CGSizeMake(frameWidth, frameHeight);
	UIImage *thumb = [image gtm_imageByResizingToSize: size preserveAspectRatio:YES
											trimToFit:NO];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(padding, padding, thumb.size.width, thumb.size.height)];
	imageView.image = thumb;
	
	[self insertSubview:imageView atIndex:0];
	[imageView release];
}

- (void)drawRect: (CGRect)rect
{
    [super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 1.0);
	
	CGContextFillRect(context, rect);
}

- (void)userDismissedContent: (id)sender
{
	[self.delegate checkAndPerformSelector: @selector(didDissmissContentToThrow)];
}

- (void)dismissKeyboard
{
	for (UIView* view in self.subviews) {
		if ([view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}

@end
