//
//  PreviewView.m
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "PreviewView.h"

#import "NSObject+DelegateHelper.h"
#import "GTMUIImage+Resize.h"

@implementation PreviewView
@synthesize delegate;


- (id) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		NSString *closeButtonPath = [[NSBundle mainBundle] pathForResource:@"close" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:closeButtonPath] forState:UIControlStateNormal];
		[button setFrame: CGRectMake(frame.size.width - 40, 0, 40, 40)];
		[button addTarget: self action: @selector(userDismissedContent:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview: button];
	}
	return self;
}

- (void) setImage: (UIImage *)image
{
	NSInteger padding = 10;
	
	CGFloat frameWidth = self.frame.size.width - (2 * padding);
	CGFloat frameHeight = self.frame.size.height - (2 * padding);
		
	CGSize size =  CGSizeMake(frameWidth, frameHeight);
	UIImage *thumb = [image gtm_imageByResizingToSize: size preserveAspectRatio:YES
											trimToFit: YES];
	
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
