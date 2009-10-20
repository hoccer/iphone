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

@implementation PreviewView
@synthesize delegate;


- (id) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
		UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button setTitle: @"Dismiss" forState:UIControlStateNormal];
		[button setFrame: CGRectMake(frame.size.width - 40, frame.size.height - 20, 60, 40)];
		[button addTarget: self action: @selector(userDismissedContent:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview: button];
	}
	return self;
}

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
	
	[self insertSubview:imageView atIndex:0];
	[imageView release];
}

- (void)drawRect: (CGRect)rect
{
    [super drawRect:rect];
	NSLog(@"drawing rect");
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	
	CGContextFillRect(context, rect);
}

- (void)userDismissedContent: (id)sender
{
	NSLog(@"dismiss");
	[self.delegate checkAndPerformSelector: @selector(didDissmissContentToThrow)];
}

@end
