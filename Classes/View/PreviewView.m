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
	
	CGFloat frameWidth = self.frame.size.width - (2 * padding);
	CGFloat frameHeight = self.frame.size.height - (2 * padding);
	
	NSInteger thumbWidth = 0;
	
	if (frameHeight < image.size.height) {
		float ratio = image.size.height / image.size.width;
		thumbWidth = frameHeight / ratio;
	} else {
		thumbWidth = frameWidth;
	}
		
	UIImage *thumb = [image acImageScaledToWidth: thumbWidth];
	UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(padding, padding, thumb.size.width, thumb.size.height)];
	imageView.image = thumb;
	
	[self insertSubview:imageView atIndex:0];
	[imageView release];
}

- (void)drawRect: (CGRect)rect
{
    [super drawRect:rect];
	
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
