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
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		NSString *closeButtonPath = [[NSBundle mainBundle] pathForResource:@"Close" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:closeButtonPath] forState:UIControlStateNormal];
		
		NSString *highlightedCloseButtonPath = [[NSBundle mainBundle] pathForResource:@"Close_Highlighted" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:highlightedCloseButtonPath] 
				forState:UIControlStateHighlighted];

		[button setFrame: CGRectMake(3, 3, 35, 36)];
		
		[self addSubview: button];
		

	}
	return self;
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

- (void) setCloseActionTarget: (id) aTarget action: (SEL) aSelector{
	[button addTarget: aTarget action: aSelector forControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touches began");
}



@end
