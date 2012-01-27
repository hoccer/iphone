//
//  ContentContainerView.m
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <unistd.h>
#import "ContentContainerView.h"
#import "NSObject+DelegateHelper.h"
#import "Preview.h"

#define kSweepBorder 50
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

- (id) initWithView: (UIView *)subview actionButtons: (NSArray *)buttons {
	self = [super initWithFrame:subview.frame];
	if (self != nil) {
		containedView = (Preview *)[subview retain];
		
		subview.center = CGPointMake(subview.frame.size.width / 2, subview.frame.size.height / 2);
		[self addSubview:subview];
        
        shineImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"content_bg_image_shine"]];
        [self addSubview:shineImage];
		
		overlay = [[UIImageView alloc] init];
		overlay.frame = ACRectShrinked(self.frame, 15, 15);
		overlay.hidden = YES;
		overlay.userInteractionEnabled = YES;

		[self addSubview:overlay];
		
		buttonContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 65, 130)]; 
		NSInteger xpos = 0;
		for (UIView *button in buttons) {
			button.frame = ACPositionedRect(button.frame, xpos, 0);
			[buttonContainer addSubview:button];
			
			xpos += button.frame.size.width;
		}

		buttonContainer.frame = CGRectMake(0, 0, xpos, ((UIView* )[buttons lastObject]).frame.size.height);
		buttonContainer.center = CGPointMake(overlay.frame.size.width / 2, overlay.frame.size.height / 2);
        [buttonContainer setBackgroundColor:[UIColor clearColor]];

		[overlay addSubview:buttonContainer];
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
	indicator.center = buttonContainer.center = CGPointMake(overlay.frame.size.width / 2, overlay.frame.size.height / 2);
	indicator.hidden = NO;
	[indicator startAnimating];
	[overlay addSubview:indicator];
	
	buttonContainer.hidden = YES;
}

- (void)hideSpinner {
	if ([[overlay subviews] count] > 1) {
		[[[overlay subviews] objectAtIndex:1] removeFromSuperview];
	}
	buttonContainer.hidden = NO;
}

- (void)showSuccess {
	[self hideOverlay];
	
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Saved";
	
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    [self addSubview:HUD];

    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
	[HUD autorelease];
}

- (void)myTask {
	sleep(1);
}

- (void)updateFrame {
    self.frame = containedView.frame;
    overlay.frame = ACRectShrinked(self.frame, 15, 15);
    buttonContainer.center = CGPointMake(overlay.frame.size.width / 2, overlay.frame.size.height / 2);
}


@end
