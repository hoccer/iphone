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
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)layoutSubviews  {
	[super layoutSubviews];
	self.titleLabel.font = [UIFont systemFontOfSize:10];
	self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.frame.size.height - 22, 
									   self.titleLabel.frame.size.width, self.titleLabel.frame.size.height); 
}

- (void)dealloc {
    [super dealloc];
}

@end
