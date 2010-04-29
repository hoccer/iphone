//
//  ContentContainerView.m
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentContainerView.h"
#import "NSObject+DelegateHelper.h"

#define kSweepBorder 50

CGRect ACPositionedRect(CGRect rect, NSInteger x, NSInteger y) {
	return CGRectMake(x, y, rect.size.width, rect.size.height);
}

CGRect ACRectShrinked(CGRect rect, NSInteger paddingX, NSInteger paddingY) {
	return CGRectMake(rect.origin.x + paddingX, rect.origin.y + paddingY, rect.size.width - (2 * paddingX), rect.size.height - (2 * paddingY));
}


@implementation ContentContainerView

@synthesize delegate;
@synthesize origin;
@synthesize containedView;

- (id) initWithView: (UIView *)subview actionButtons: (NSArray *)buttons {
	self = [super initWithFrame:subview.frame];
	if (self != nil) {
		containedView = [subview retain];
		
		subview.center = CGPointMake(subview.frame.size.width / 2, subview.frame.size.height / 2);
		[self addSubview:subview];
		
		overlay = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"container_overlay.png"]];
		overlay.frame = ACRectShrinked(self.frame, 15, 15);
		overlay.hidden = YES;
		overlay.userInteractionEnabled = YES;
		
		UIView *buttonContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 65, 110)]; 
		NSInteger xpos = 0;
		for (UIView *button in buttons) {
			button.frame = ACPositionedRect(button.frame, xpos, 0);
			[buttonContainer addSubview:button];
			
			xpos += button.frame.size.width;
		}
		
		buttonContainer.frame = CGRectMake(0, 0, xpos, ((UIView* )[buttons lastObject]).frame.size.height);
		buttonContainer.center = overlay.center;
		[overlay addSubview:buttonContainer];
		
		[self addSubview:overlay];
	}
	return self;
}

- (void) dealloc {
	[containedView release];
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
