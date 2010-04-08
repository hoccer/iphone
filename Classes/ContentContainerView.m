//
//  ContentContainerView.m
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ContentContainerView.h"
#import "NSObject+DelegateHelper.h"

#define kSweepBorder 50

@implementation ContentContainerView

@synthesize delegate;
@synthesize origin;
@synthesize containedView;

- (id) initWithView: (UIView *)subview
{
	self = [super initWithFrame:subview.frame];
	if (self != nil) {
		containedView = [subview retain];
		
		subview.center = CGPointMake(subview.frame.size.width / 2, subview.frame.size.height / 2);
		[self addSubview:subview];
		
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		NSString *closeButtonPath = [[NSBundle mainBundle] pathForResource:@"Close" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:closeButtonPath] forState:UIControlStateNormal];
		
		NSString *highlightedCloseButtonPath = [[NSBundle mainBundle] pathForResource:@"Close_Highlighted" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:highlightedCloseButtonPath] 
				forState:UIControlStateHighlighted];
		
		[button addTarget: self action: @selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
		[button setFrame: CGRectMake(3, 3, 35, 36)];
		
		[self addSubview: button];
	}
	return self;
}

- (void) dealloc
{
	[containedView release];
	[button release];
	
	[super dealloc];
}

- (void)setOrigin:(CGPoint)newOrigin {
	CGRect frame = self.frame;
	frame.origin = newOrigin;
	self.frame = frame;
}

- (void)closeView: (id)sender {
	if ([delegate respondsToSelector:@selector(containerViewDidClose:)]) {
		[delegate containerViewDidClose:self];
	}
}

#pragma mark -
#pragma mark animations
- (void)resetViewAnimated: (BOOL)animated {
	CGRect myRect = self.frame;
	myRect.origin = origin;
	
	self.frame = myRect;
	self.userInteractionEnabled = YES;
}

- (void)moveBy: (CGSize) distance {
	CGRect myRect = self.frame;
	myRect.origin.x += distance.width; 
	myRect.origin.y += distance.height; 
	
	self.frame = myRect;
}

- (BOOL)willStayInView: (UIView *)view afterMovedBy: (CGSize) distance {
	return YES;
}



@end
