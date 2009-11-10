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

- (void)expandScrollView;
- (void)shrinkScrollView;

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


- (IBAction)showHiddenView: (id)sender
{
	[self expandScrollView];
	
	[scrollView setContentOffset:CGPointMake(0, hiddenView.frame.size.height) animated:YES];
}


#pragma mark -
#pragma mark ScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate
{
	CGFloat yOffset =  scrollView.contentOffset.y;
	if (yOffset > hiddenView.frame.size.height + 5) {
		[self expandScrollView];
	} else {
		[self shrinkScrollView];
		
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

- (void)setIndicatorView: (UIButton *)view
{
	[view retain];
	[indicatorView release];
	
	indicatorView = view;
	
	[view addTarget:self action:@selector(indicatorTriggered:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)indicatorTriggered: (id)sender
{
	if (!expanded) {
		[self expandScrollView];
		[self.scrollView setContentOffset: CGPointMake(0, self.hiddenView.frame.size.height) 
								 animated: YES];
	} else {
		[self shrinkScrollView];
		[self.scrollView setContentOffset:CGPointMake(0, 0) animated: YES];
	}
}


#pragma mark -
#pragma mark Private Methods

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

- (void)expandScrollView
{
	CGFloat yOffset =  scrollView.contentOffset.y;

	CGSize size = scrollView.frame.size;
	size.height = size.height + hiddenView.frame.size.height;
	scrollView.contentSize = size;
	scrollView.contentOffset = CGPointMake(0, yOffset);
	
	expanded = YES;
}

- (void)shrinkScrollView
{
	CGFloat yOffset =  scrollView.contentOffset.y;

	scrollView.contentSize = CGSizeMake(320, 460);
	scrollView.contentOffset = CGPointMake(0, yOffset);

	expanded = NO;
}


@end
