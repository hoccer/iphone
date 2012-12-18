//
//  ContentContainerView.m
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <unistd.h>
#import "ContentContainerView.h"
#import "NSObject+DelegateHelper.h"
#import "Preview.h"

CGRect ACPositionedRect(CGRect rect, NSInteger x, NSInteger y);
CGRect ACRectShrinked(CGRect rect, NSInteger paddingX, NSInteger paddingY);

CGRect ACPositionedRect(CGRect rect, NSInteger x, NSInteger y) {
	return CGRectMake(x, y, rect.size.width, rect.size.height);
}

CGRect ACRectShrinked(CGRect rect, NSInteger paddingX, NSInteger paddingY) {
	return CGRectMake(rect.origin.x + paddingX, rect.origin.y + paddingY, rect.size.width - (2 * paddingX), rect.size.height - (2 * paddingY));
}


@implementation ContentContainerView

@synthesize delegate;
@synthesize origin;
@synthesize buttonContainer;
@synthesize containedView;

- (id) initWithView: (UIView *)subview actionButtons:(NSArray *)buttons {
	self = [super initWithFrame:subview.frame];
	if (self != nil) {
		containedView = (Preview *)[subview retain];
		
		subview.center = CGPointMake(subview.frame.size.width / 2, subview.frame.size.height / 2);
		[self addSubview:subview];
		

        buttonContainer = [[UIView alloc] initWithFrame: CGRectMake(18, 165, 90, 41)];
		NSInteger xpos = 0;
		for (UIView *button in buttons) {
			button.frame = ACPositionedRect(button.frame, xpos, 0);
			[buttonContainer addSubview:button];
			
			xpos += button.frame.size.width;
		}
        buttonContainer.hidden = ![containedView allowsOverlay];
		[self addSubview:buttonContainer];
	}
	return self;
}

- (void)dealloc {
	[containedView release];
	[overlay release];
	[buttonContainer release];
	
	[super dealloc];
}

- (void) setContainedView:(Preview *)newContainedView {
	if (containedView != newContainedView) {
		[containedView removeFromSuperview];
		[self insertSubview:newContainedView atIndex:[self.subviews count]-1];
		
		[containedView release];
		containedView = [newContainedView retain];
        buttonContainer.hidden = ![containedView allowsOverlay];
	}
}

- (IBAction)toggleOverlay: (id)sender {
	if ([containedView allowsOverlay]) {
		overlay.hidden = !overlay.hidden;
	}
}

- (void)hideOverlay {
	overlay.hidden = YES;
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

- (void)showSpinner {
	UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	indicator.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
	indicator.hidden = NO;
	[indicator startAnimating];
	[self addSubview:indicator];
	
}

- (void)hideSpinner {
	if ([[self subviews] count] > 1) {
		for (id view in [self subviews])
            if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
                [view removeFromSuperview];
            }
	}
	buttonContainer.hidden = NO;
}

- (void)showSuccess {	
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:HUD];

    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]] autorelease];

	HUD.mode = MBProgressHUDModeCustomView;

	HUD.labelText = @"Saved";
	HUD.minShowTime = 1;

    [HUD show:YES];
    [HUD hide:YES];
	[HUD autorelease];
}

- (void)updateFrame {
    self.frame = containedView.frame;
    [buttonContainer setFrame:CGRectMake(18, 165, 90, 41)];

    
}


@end
