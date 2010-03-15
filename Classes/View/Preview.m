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
@synthesize delegate;
@synthesize origin;



- (id) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame:frame];	
	if (self != nil) {
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		NSString *closeButtonPath = [[NSBundle mainBundle] pathForResource:@"Close" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:closeButtonPath] forState:UIControlStateNormal];
		
		NSString *highlightedCloseButtonPath = [[NSBundle mainBundle] pathForResource:@"Close_Highlighted" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:highlightedCloseButtonPath] 
				forState:UIControlStateHighlighted];

		[button setFrame: CGRectMake(3, 3, 35, 36)];
		[button addTarget: self action: @selector(userDismissedContent:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview: button];
		
		self.origin = frame.origin;
	}
	return self;
}

- (void)setOrigin: (CGPoint)newOrigin {
	origin = newOrigin;
	
	[self resetViewAnimated: NO];
}


- (void) setImage: (UIImage *)image
{
	NSInteger paddingLeft = 35;
	NSInteger paddingTop = 35;
	
	CGFloat frameWidth = self.frame.size.width - (2 * paddingLeft) + 3;
	CGFloat frameHeight = self.frame.size.height - (2 * paddingTop) + 10;
		
	CGSize size =  CGSizeMake(frameWidth, frameHeight);
	UIImage *thumb = [image gtm_imageByResizingToSize: size preserveAspectRatio:YES
											trimToFit: YES];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(paddingLeft, paddingTop, size.width, size.height)];
	imageView.image = thumb;
	
	[self insertSubview:imageView atIndex:1];
	[imageView release];
}

- (void)resetViewAnimated: (BOOL)animated {
	CGRect myRect = self.frame;
	myRect.origin = origin;
	self.frame = myRect;
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touches began");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{	
	
	UITouch* touch = [touches anyObject];
	CGPoint prevLocation = [touch previousLocationInView: self.superview];
	CGPoint currentLocation = [touch locationInView: self.superview];
	
	CGRect myRect = self.frame;
	myRect.origin.x += currentLocation.x - prevLocation.x; 
	myRect.origin.y += currentLocation.y - prevLocation.y; 
	
	self.frame = myRect;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{	
	[self resetViewAnimated:YES];	
		
	NSLog(@"touches ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touches cancelled");
}

@end
