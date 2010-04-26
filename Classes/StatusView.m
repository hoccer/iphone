//
//  StatusView.m
//  Hoccer
//
//  Created by Robert Palmer on 26.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "StatusView.h"
#import <QuartzCore/QuartzCore.h>


@implementation StatusView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
    return self;
}

//- (void)awakeFromNib {
//	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//	
//	gradientLayer.frame = self.frame;
//	
//	CGColorRef darkColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1].CGColor;
//	CGColorRef lightColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1].CGColor;
//	
//	gradientLayer.colors = [NSArray arrayWithObjects: (id)darkColor, (id)lightColor, nil];
////	[gradientLayer addConstraint:[CAConstr constraintWithAttribute:kCAConstraintHeight
////													 relativeTo:@"superlayer"
////													  attribute:kCAConstraintHeight]];
//	[self.layer insertSublayer:gradientLayer atIndex:0];
//	
//	self.backgroundColor = [UIColor clearColor];
//}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//}


- (void)dealloc {
    [super dealloc];
}


@end
