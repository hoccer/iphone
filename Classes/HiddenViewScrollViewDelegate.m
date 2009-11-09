//
//  HiddenViewScrollViewDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 05.11.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HiddenViewScrollViewDelegate.h"


@interface HiddenViewScrollViewDelegate ()

- (void)turnIndicatorDown;
- (void)turnIndicatorUp;

@end

@implementation HiddenViewScrollViewDelegate

@synthesize scrollView;
@synthesize indicatorView;
@synthesize hiddenView;


- (void) dealloc
{
	[scrollView release];
	[indicatorView release];
	[hiddenView release];
	
	[super dealloc];
}



#pragma mark -
#pragma mark ScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate
{
	CGFloat yOffset =  scrollView.contentOffset.y;
	if (yOffset > hiddenView.frame.size.height + 5) {
		CGSize size = scrollView.frame.size;
		size.height += hiddenView.frame.size.height;
		scrollView.contentSize = size;
		scrollView.contentOffset = CGPointMake(0, yOffset);
	} else {
		scrollView.contentSize = CGSizeMake(320, 460);
		scrollView.contentOffset = CGPointMake(0, yOffset);
	
		if (!decelerate) {
			[self scrollViewDidEndDecelerating:aScrollView];
		}
	}
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
	float maxHeight = hiddenView.frame.size.height;
	if (scrollView.contentOffset.y < maxHeight ) {
	 	[scrollView setContentOffset: CGPointMake(0, 0) animated:YES];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{	
	if (scrollView.contentOffset.y >= hiddenView.frame.size.height) {
		[self turnIndicatorDown];
	} else {
		[self turnIndicatorUp];
	}
}


- (void)turnIndicatorDown
{
	if (!indicatorIsTurnedUp)
		return;
	
	[UIView beginAnimations:@"turnDownAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	indicatorView.transform = CGAffineTransformMakeRotation(3.14);	
	[UIView commitAnimations];
	
	indicatorIsTurnedUp = NO;
}

- (void)turnIndicatorUp
{	
	if (indicatorIsTurnedUp)
		return;
	
	[UIView beginAnimations:@"rotateUpAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	indicatorView.transform = CGAffineTransformIdentity;	
	[UIView commitAnimations];
	
	indicatorIsTurnedUp = YES;
	
}



@end
