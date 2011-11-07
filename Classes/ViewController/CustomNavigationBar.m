//
//  CustomNavigationBar.m
//  Hoccer
//
//  Created by Philip Brechler on 03.11.11.
//  Copyright (c) 2011 Hoccer GmbH. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

- (void)drawRect: (CGRect)dirtyRect {
	UIImage *image = [UIImage imageNamed: @"hoccer_bar.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end
