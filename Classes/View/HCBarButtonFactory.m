//
//  HCBarButtonFactory.m
//  Hoccer
//
//  Created by patrick on 13.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCBarButtonFactory.h"


@implementation HCBarButtonFactory


+ (UIBarButtonItem *)newItemWithTitle:(NSString *)title style:(HCBarButtonStyle)style target:(id)target action:(SEL)selector {
    
    return [self newItemWithTitle:title
                           target:target
                           action:selector
              backgroundImageName:[HCBarButtonFactory _backgroundImageNameForStyle:style]
                      textPadding:10.0f];
}



+ (UIBarButtonItem *)newItemWithTitle:(NSString *)title
                               target:(id)target
                                     action:(SEL)selector
                        backgroundImageName:(NSString *)backgroundImageName
                                textPadding:(float)textPadding {
    
    // Resizable image background
    UIImage *buttonImage = [[UIImage imageNamed:backgroundImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 6, 15, 6)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    // Resize button to fit text + padding
    UIFont *buttonFont = [UIFont boldSystemFontOfSize:12];
    CGSize requiredSize = [title sizeWithFont:buttonFont];
    requiredSize.width += roundf(textPadding * 2.0f);    // Padding in front of and after text
    button.frame = CGRectMake(0, 0, MAX(20.0f, requiredSize.width), 32);
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = buttonFont;
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

+ (NSString *)_backgroundImageNameForStyle:(HCBarButtonStyle)style {
    
    switch (style) {
        case HCBarButtonBlue:
            return @"nav_bar_btn_blue_background";
            
        case HCBarButtonBlack:
        default:
            return @"nav_bar_btn_background";            
    }
}


@end
