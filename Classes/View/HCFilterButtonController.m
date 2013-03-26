//
//  HCFilterButtonController.m
//  Hoccer
//
//  Created by patrick on 26.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCFilterButtonController.h"
#import "HCFilterButton.h"


#define kHCFilterButtonControllerPadding    0.0f


@interface HCFilterButtonController()
@property (nonatomic, retain) NSMutableArray *buttons;
@end


@implementation HCFilterButtonController


- (void)dealloc
{
    [_buttons release];
    [super dealloc];
}

- (id)initWithTitles:(NSArray *)titles target:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
        self.view = view;
        [view release];
        
        self.target = target;
        self.action = action;
        
        self.buttons = [NSMutableArray arrayWithCapacity:titles.count];
        float x = 0.0f;
        for (NSString *title in titles) {
            HCFilterButton *button = [[HCFilterButton alloc] initWithTitle:title target:self action:@selector(didSelectFilter:)];
            button.frame = CGRectMake(x, 0.0f, 1.0f, 1.0f);
            x += CGRectGetWidth(button.frame) + kHCFilterButtonControllerPadding;
            [self.view addSubview:button];
            [self.buttons addObject:button];
            [button release];
        }
        
        view.frame = CGRectMake(0.0f, 0.0f, x, 30.0f);
        
    }
    return self;
}


- (NSUInteger)selectedIndex {
    
    NSUInteger index = 0;
    for (HCFilterButton *button in _buttons) {
        if (button.selected) return index;
        ++index;
    }
    
    return NSNotFound;
}

- (void)buttonWithIndex:(NSUInteger)index selected:(BOOL)selected {
    
    HCFilterButton *targetedButton = (HCFilterButton *)[self.buttons objectAtIndex:index];
    for (HCFilterButton *button in _buttons) {
        if (button != targetedButton) button.selected = NO;
    }
    targetedButton.selected = selected;
    
    [self.target performSelector:self.action withObject:self];
}

- (void)didSelectFilter:(id)sender {

    HCFilterButton *button = (HCFilterButton *)sender;
    NSUInteger index = [self.buttons indexOfObject:button];
    [self buttonWithIndex:index selected:YES];
}

@end
