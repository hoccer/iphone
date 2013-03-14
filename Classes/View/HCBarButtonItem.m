//
//  HCBarButtonItem.m
//  Hoccer
//
//  Created by Patrick Juchli on 14.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCBarButtonItem.h"


@implementation HCBarButtonItem

- (void)setEnabled:(BOOL)enabled {
    
    [super setEnabled:enabled];
    
    // Hint: If you find that setting enabled to NO has no effect
    // on the transparency of your button, please make set enabled
    // *after* adding this item no a UINavigationItem.
    if (self.customView) {
        self.customView.alpha = enabled ? 1.0f : 0.4f;
    }
}

@end
