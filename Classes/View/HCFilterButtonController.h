//
//  HCFilterButtonController.h
//  Hoccer
//
//  Created by patrick on 26.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCFilterButtonController : NSObject

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) UIView *view;

- (id)initWithTitles:(NSArray *)titles target:(id)target action:(SEL)action;
- (void)buttonWithIndex:(NSUInteger)index selected:(BOOL)selected;
- (NSUInteger)selectedIndex;

@end
