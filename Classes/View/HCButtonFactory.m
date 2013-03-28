//
//  HCBarButtonFactory.m
//  Hoccer
//
//  Created by Patrick Juchli on 13.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCButtonFactory.h"


#define kHCButtonHeight         32.0f


@implementation HCButtonFactory


+ (HCBarButtonItem *)newItemWithTitle:(NSString *)title style:(HCButtonStyle)style target:(id)target action:(SEL)selector {
    
    UIButton *button = [self buttonWithTitle:title style:style target:target action:selector];
    HCBarButtonItem *barButtonItem = [[HCBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}


+ (UIButton *)buttonWithTitle:(NSString *)title style:(HCButtonStyle)style target:(id)target action:(SEL)selector {

    UIImage *backgroundImage = [self _resizableImageForStyle:style];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    UIFont *buttonFont = [self _fontForStyle:style];
    CGSize requiredSize = [title sizeWithFont:buttonFont];
    
    float textPadding = [self _paddingForStyle:style];
    requiredSize.width += roundf(textPadding * 2.0f);
    button.frame = CGRectMake(0, 0, MAX(20.0f, requiredSize.width), kHCButtonHeight);
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = buttonFont;
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        
    return button;
}


+ (HCBarButtonItem *)newSegmentedControlWithImages:(NSArray *)images target:(id)target action:(SEL)selector {
    
    CGRect containingRect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIView *buttonContainer = [[UIView alloc] initWithFrame:containingRect];
    
    NSUInteger currentTag = 0;
    for (UIImage *image in images) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setTag:currentTag];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(CGRectGetMaxX(containingRect), 0.0f, image.size.width, image.size.height);
        
        ++currentTag;
        [buttonContainer addSubview:button];
        containingRect = CGRectUnion(containingRect, button.frame);
    }

    buttonContainer.frame = containingRect;
    HCBarButtonItem *segmentedControlItem = [[HCBarButtonItem alloc] initWithCustomView:buttonContainer];
    [buttonContainer release];
    
    return segmentedControlItem;
}


+ (float)_paddingForStyle:(HCButtonStyle)style {
    switch (style) {
        case HCButtonStyleBlackLarge:
            return 11.0f;
            break;
            
        default:
            return 9.0f;
            break;
    }
}

+ (UIFont *)_fontForStyle:(HCButtonStyle)style {
    
    switch (style) {
        case HCButtonStyleBlackLarge:
            return [UIFont systemFontOfSize:17];
            break;
            
        default:
            return [UIFont boldSystemFontOfSize:12];
            break;
    }
}


+ (UIImage *)_resizableImageForStyle:(HCButtonStyle)style {
    
    NSString *backgroundImageName;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    
    switch (style) {
        case HCButtonStyleBlue:
            backgroundImageName = @"nav_bar_btn_blue_background";
            break;
            
        case HCButtonStyleRed:
            backgroundImageName = @"nav_bar_btn_red_background";
            break;
        
        case HCButtonStyleBlackPointingLeft:
            edgeInsets = UIEdgeInsetsMake(0, 14, 0, 6);
            backgroundImageName = @"nav_bar_btn_back";
            break;
            
        case HCButtonStyleBlack:
        default:
            backgroundImageName = @"nav_bar_btn_background";
            break;
    }
    
    UIImage *image = [UIImage imageNamed:backgroundImageName];
    CGFloat topInset = floorf(image.size.height / 2.0f);
    edgeInsets.top = edgeInsets.bottom = topInset;
    
    return [image resizableImageWithCapInsets:edgeInsets];
}


@end
