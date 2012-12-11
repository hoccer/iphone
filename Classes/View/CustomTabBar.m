//
//  CustomTabBar.m
//  Hoccer
//
//  Created by Robert Palmer on 03.05.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "CustomTabBar.h"


@implementation CustomTabBar

- (void)drawRect: (CGRect)dirtyRect {
    UIImage *image;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        image = [UIImage imageNamed: @"tab_bar_bg"];
    }
    else {
        image = [UIImage imageNamed:@"nav_bar"];
    }
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end