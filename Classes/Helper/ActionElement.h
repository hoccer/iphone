//
//  ActionElement.h
//  Hoccer
//
//  Created by Philip Brechler on 03.11.11.
//  Copyright (c) 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionElement : NSObject
{
	id target;
	SEL selector;
}

+ (ActionElement *)actionElementWithTarget: (id)aTarget selector: (SEL)selector;
- (id)initWithTargat: (id)aTarget selector: (SEL)selector;
- (void)perform;

@end
