//
//  HCUtils.m
//  Hoccer
//
//  Created by patrick on 28.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCUtils.h"


float HCRoundValueForDisplayScale(float value) {
    float screenScale = [[UIScreen mainScreen] scale];
    return roundf(value * screenScale) / screenScale;
}
