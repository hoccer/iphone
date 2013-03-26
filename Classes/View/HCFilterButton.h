//
//  HCFilterButton.h
//  Hoccer
//
//  Created by patrick on 22.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCFilterButton : UIView

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;

- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
