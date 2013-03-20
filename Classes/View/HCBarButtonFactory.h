//
//  HCBarButtonFactory.h
//  Hoccer
//
//  Created by Patrick Juchli on 13.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCBarButtonItem.h"


typedef enum {
	HCBarButtonBlack,
	HCBarButtonBlue,
	HCBarButtonRed,
    HCBarButtonBlackPointingLeft
} HCBarButtonStyle;


@interface HCBarButtonFactory : NSObject


+ (HCBarButtonItem *)newItemWithTitle:(NSString *)title style:(HCBarButtonStyle)style target:(id)target action:(SEL)selector;

+ (HCBarButtonItem *)newSegmentedControlWithImages:(NSArray *)images target:(id)target action:(SEL)selector;


@end
