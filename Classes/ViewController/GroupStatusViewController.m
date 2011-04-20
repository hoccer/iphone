//
//  GroupStatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 19.04.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "GroupStatusViewController.h"


@implementation GroupStatusViewController


- (void)calculateHightForText: (NSString *)text {
    NSLog(@"calculating height");
    CGRect frame = self.view.frame;
	frame.size.height = 100;
    self.view.frame = frame;
	
    self.view.backgroundColor = [UIColor colorWithPatternImage:self.largeBackground];	
}

- (void)setGroup: (NSArray *)group {
    [self calculateHightForText:@"bla"];
}


@end
