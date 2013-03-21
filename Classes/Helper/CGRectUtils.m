//
//  CGRectUtils.m
//  Hoccer
//
//  Created by patrick on 14.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "CGRectUtils.h"


CGRect CGRectSetOriginY(CGRect existingRect, float newOriginY) {
    existingRect.origin.y = newOriginY;
    return existingRect;
}

CGPoint CGPointRound(CGPoint existingPoint) {
    existingPoint.x = roundf(existingPoint.x);
    existingPoint.y = roundf(existingPoint.y);
    return existingPoint;
}