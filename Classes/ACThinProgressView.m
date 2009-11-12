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

	CGContextSetRGBFillColor(context, 0.25, 0.25, 0.25, 1.0);
	CGRect progressBarRect = CGRectMake(0, 6,  rect.size.width, 3);
	CGContextFillRect(context, progressBarRect);

	CGContextSetRGBFillColor(context, 0.09, 0.84, 0.86, 1.0);
	CGRect progressRect = CGRectMake(0, 6, progressWidth, 3);
	CGContextFillRect(context, progressRect);
}


- (void)dealloc {
    [super dealloc];
}


@end
