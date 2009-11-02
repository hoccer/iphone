//
//  ACThinProgressView.m
//  Hoccer
//
//  Created by Robert Palmer on 02.11.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ACThinProgressView.h"


@implementation ACThinProgressView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	float progressWidth = rect.size.width * self.progress;
	
	CGContextSetRGBFillColor(context, 0.85, 0.85, 0.85, 1.0);
	CGContextFillRect(context, rect);

	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGRect progressBarRect = CGRectMake(0, 0,  rect.size.width, 2);
	CGContextFillRect(context, progressBarRect);

	CGContextSetRGBFillColor(context, 0.26, 0.26, 0.26, 1.0);
	CGRect progressRect = CGRectMake(0, 0, progressWidth, 2);
	CGContextFillRect(context, progressRect);
}


- (void)dealloc {
    [super dealloc];
}


@end
