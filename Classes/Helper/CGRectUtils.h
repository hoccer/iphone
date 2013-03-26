//
//  CGRectUtils.h
//  Hoccer
//
//  Created by patrick on 14.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

CGRect CGRectSetOrigin(CGRect existingRect, float x, float y);
CGRect CGRectSetOriginY(CGRect existingRect, float newOriginY);

CGPoint CGPointRound(CGPoint existingPoint);