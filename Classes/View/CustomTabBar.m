//
//  CustomTabBar.m
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "CustomTabBar.h"


@implementation CustomTabBar

- (void)drawRect: (CGRect)dirtyRect {
	UIImage *image = [UIImage imageNamed: @"nav_bar.png"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        image = [UIImage imageNamed:@"tab_bar_ipad"];
    }
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end