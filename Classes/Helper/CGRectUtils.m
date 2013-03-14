//
//  CGRectUtils.m
//  Hoccer
//
//  Created by patrick on 14.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "CGRectUtils.h"

CGRect CGRectSetOriginY(CGRect existingRect, float newOriginY) {
    CGRect newRect = existingRect;
    newRect.origin.y = newOriginY;
    return newRect;
}