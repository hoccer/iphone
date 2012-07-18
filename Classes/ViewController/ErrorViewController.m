//
//  ErrorViewController.m
//  Hoccer
//
//  Created by Philip Brechler on 14.06.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "ErrorViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ErrorViewController

@synthesize titleLabel,messageLabel;

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"errorbar_bg"]];
	self.view.hidden = YES;	
}

- (void)showError:(NSError *)error forSeconds:(NSTimeInterval)time {
    NSString *ourText = error.localizedDescription;
    
    self.messageLabel.text = ourText;
    
     
    [self showViewAnimated:YES];
    if (timer != nil) {
		[timer invalidate];
		[timer release];
	}
	
	timer = [[NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(hideStatus) userInfo:nil repeats:NO] retain];
}

- (void)hideStatus {
	[self hideViewAnimated:YES];
}

- (IBAction)hideView:(id)sender {
    [self hideViewAnimated:YES];
}

#pragma mark -
#pragma mark Showing and Hiding StatusBar

- (void)showViewAnimated: (BOOL)animation {
	if (!self.view.hidden ) {
		return;
	}
    
	self.view.hidden = NO;
	
	if (animation) {
		CGFloat currentYPos = self.view.center.y;
		
		self.view.center = CGPointMake(self.view.center.x, currentYPos - 100);
		[UIView beginAnimations:@"slideDown" context:nil];
		self.view.center = CGPointMake(self.view.center.x, currentYPos);
		[UIView commitAnimations];	
	}
}

- (void)hideViewAnimated: (BOOL)animation {	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
        if (animation) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x, - 120)];
            animation.fillMode = kCAFillModeBoth;
            animation.removedOnCompletion = NO;
            animation.duration = 0.2;
            animation.delegate = self;
            
            [self.view.layer addAnimation:animation forKey:@"slideUp"];		
        } else {
            self.view.hidden = YES;
        }
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	self.view.hidden = YES;
	[self.view.layer removeAllAnimations];
}


@end
