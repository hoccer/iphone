//
//  HiddenViewScrollViewDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 05.11.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

@interface HiddenViewScrollViewDelegate

- (void)turnIndicatorDown;
- (void)turnIndicatorUp;

@end



#import "HiddenViewScrollViewDelegate.h"


@implementation HiddenViewScrollViewDelegate

@synthesize scrollView;
@synthesize indicatorView;

#pragma mark -
#pragma mark ScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	CGFloat yOffset =  scrollView.contentOffset.y;
	
	if (yOffset > selectionViewController.view.frame.size.height + 5) {
		
		CGSize size = mainScrollView.frame.size;
		size.height += selectionViewController.view.frame.size.height;
		mainScrollView.contentSize = size;
		
		scrollView.contentOffset = CGPointMake(0, yOffset);
	} else {
		mainScrollView.contentSize = CGSizeMake(320, 460);
		scrollView.contentOffset = CGPointMake(0, yOffset);
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	float maxHeight = selectionViewController.view.frame.size.height;
	if (scrollView.contentOffset.y > maxHeight ) {
		[scrollView setContentOffset: CGPointMake(0, maxHeight) animated:YES];
	}
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.y >= selectionViewController.view.frame.size.height) {
		[self turnIndicatorDown];
	} else {
		[self turnIndicatorUp];
	}
}


- (void)turnIndicatorDown
{
	NSLog(@"turning down");
	
	[UIView beginAnimations:@"turnDownAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	downIndicator.transform = CGAffineTransformMakeRotation(3.14);	
	[UIView commitAnimations];
}

- (void)turnIndicatorUp
{
	NSLog(@"turning up");
	
	[UIView beginAnimations:@"rotateUpAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	downIndicator.transform = CGAffineTransformIdentity;	
	[UIView commitAnimations];
	
}



@end
