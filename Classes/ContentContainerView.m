//
//  ContentContainerView.m
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ContentContainerView.h"


@implementation ContentContainerView

- (id) initWithView: (UIView *)insideView
{
	self = [super initWithFrame:insideView.frame];
	if (self != nil) {
		insideView.center = CGPointMake(insideView.frame.size.width / 2, insideView.frame.size.height / 2);
		[self addSubview:insideView];
		
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

- (void) setCloseActionTarget: (id) aTarget action: (SEL) aSelector{
	[button addTarget: aTarget action: aSelector forControlEvents:UIControlEventTouchUpInside];
}


@end
