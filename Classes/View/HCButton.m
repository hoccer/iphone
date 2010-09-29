//
//  HCButtonView.m
//  Hoccer
//
//  Created by Robert Palmer on 03.08.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HCButton.h"


@implementation HCButton


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		textLabelOffset = 0;
    }
    return self;
}

- (void)layoutSubviews  {
	[super layoutSubviews];
	self.titleLabel.font = [UIFont boldSystemFontOfSize:10];
	self.titleLabel.textColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1];
	self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x + textLabelOffset, self.frame.size.height - 22, 
									   self.titleLabel.frame.size.width, self.titleLabel.frame.size.height); 
	textLabelOffset = 0;
}

- (void)setTextLabelOffset: (CGFloat)newOffset {
	textLabelOffset = newOffset;
}

- (void)dealloc {
    [super dealloc];
}

@end
 