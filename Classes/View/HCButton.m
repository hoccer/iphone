//
//  HCButtonView.m
//  Hoccer
//
//  Created by Robert Palmer on 03.08.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "HCButton.h"

@implementation HCButton

- (id)initWithFrame:(CGRect)frame {    
    self = [super initWithFrame:frame];
    if (self) {
        [self _initDefault];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initDefault];
    }
    return self;
}

- (void)_initDefault {
    self.fontSize = 8.0f;
    self.verticalTextOffset = 14.0f;
    self.horizontalTextOffset = 0.0f;
}

- (void)layoutSubviews  {
    
 	[super layoutSubviews];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:self.fontSize];
	self.titleLabel.textColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1];
	self.titleLabel.frame = CGRectMake(self.horizontalTextOffset,
                                       self.frame.size.height - self.verticalTextOffset,
									   CGRectGetWidth(self.bounds),
                                       self.titleLabel.frame.size.height);
}

- (void)setVerticalTextOffset:(CGFloat)verticalTextOffset {
    _verticalTextOffset = verticalTextOffset;
    [self setNeedsLayout];
}

- (void)setHorizontalTextOffset:(CGFloat)horizontalTextOffset {
    _horizontalTextOffset = horizontalTextOffset;
    [self setNeedsLayout];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    [self setNeedsLayout];
}

@end
 