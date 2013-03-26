//
//  HCFilterButton.m
//  Hoccer
//
//  Created by patrick on 22.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCFilterButton.h"
#import "CGRectUtils.h"


#define kHCFilterButtonHeight   30.0f


@interface HCFilterButton()
@property (nonatomic, assign) UIControlState state;
@end


@implementation HCFilterButton


- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, kHCFilterButtonHeight, kHCFilterButtonHeight)];
    if (self) {
        
        self.title = title;
        self.target = target;
        self.action = action;
        self.opaque = NO;
        self.multipleTouchEnabled = NO;
        self.state = UIControlStateNormal;
        self.selected = NO;
        
        [self sizeToFitLabel];        
    } 
    return self;
}

- (void)setFrame:(CGRect)frame {
    
    CGSize labelSize = [self requiredLabelSize];
    frame = CGRectSetSize(frame, labelSize.width + kHCFilterButtonHeight, kHCFilterButtonHeight);
    [super setFrame:frame];
}

- (void)setState:(UIControlState)state {
    _state = state;
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.state = selected ? UIControlStateSelected : UIControlStateNormal;
}

- (void)sizeToFitLabel {
    CGSize labelSize = [self requiredLabelSize];
    self.frame = CGRectSetSize(self.frame, labelSize.width + kHCFilterButtonHeight, kHCFilterButtonHeight);
}

- (UIFont *)labelFont {
    return [UIFont fontWithName:@"Helvetica-Bold" size:14];
}

- (CGSize)requiredLabelSize {
    return [self.title sizeWithFont:[self labelFont]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIControlStateHighlighted;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.selected = YES;
    [self.target performSelector:self.action withObject:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}


- (void)drawRect:(CGRect)rect {

    CGRect buttonRect = self.bounds;
    UIColor *backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    
    if (self.state == UIControlStateSelected || self.state == UIControlStateHighlighted) {
        UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:buttonRect.size.height / 2.0f];
        [backgroundColor setFill];
        [backgroundPath fill];
    }
        
    UIColor *labelColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    [labelColor setFill];
    CGSize labelSize = [self requiredLabelSize];
    [self.title drawInRect:CGRectInset(buttonRect, 0, floorf((kHCFilterButtonHeight - labelSize.height) / 2.0f))
                  withFont:[self labelFont]
             lineBreakMode:NSLineBreakByWordWrapping
                 alignment:NSTextAlignmentCenter];
}

@end
