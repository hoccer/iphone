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
		
		overlay = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"container_bild_overlay.png"]];
		overlay.frame = self.frame;
		overlay.hidden = YES;
		overlay.userInteractionEnabled = YES;
		
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setImage:[UIImage imageNamed:@"container_btn_single-close.png"] forState:UIControlStateNormal];
		[button addTarget: self action: @selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
		[button setFrame: CGRectMake(3, 3, 70, 61)];
		button.center = self.center;
		
		[overlay addSubview:button];
		
		[self addSubview:overlay];
	}
	return self;
}

- (void) dealloc {
	[containedView release];
	[button release];
	[overlay release];
	
	[super dealloc];
}

- (IBAction)toggleOverlay: (id)sender {
	overlay.hidden = !overlay.hidden;
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
