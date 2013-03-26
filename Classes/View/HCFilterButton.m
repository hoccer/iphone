//
//  HCFilterButton.m
//  Hoccer
//
//  Created by patrick on 22.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCFilterButton.h"

@implementation HCFilterButton


- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f)];
    if (self) {
        
        self.title = title;
        self.target = target;
        self.action = action;
        self.opaque = NO;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {

    CGRect buttonRect = CGRectMake(0.0f, 0.0f, 100.0f, 30.0f);
    UIColor *backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    UIColor *labelColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:buttonRect.size.height / 2.0f];
    [backgroundColor setFill];
    [backgroundPath fill];
    
    [labelColor setFill];
    [self.title drawInRect:CGRectInset(buttonRect, 0, 6)
                  withFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]
             lineBreakMode:NSLineBreakByWordWrapping
                 alignment:NSTextAlignmentCenter];
}

@end
