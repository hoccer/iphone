//
//  HCBarButtonFactory.h
//  Hoccer
//
//  Created by patrick on 13.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	HCBarButtonBlack,
	HCBarButtonBlue,
	HCBarButtonRed,
    HCBarButtonBlackPointingLeft
} HCBarButtonStyle;


@interface HCBarButtonFactory : NSObject

+ (UIBarButtonItem *)newItemWithTitle:(NSString *)title style:(HCBarButtonStyle)style target:(id)target action:(SEL)selector;

@end
