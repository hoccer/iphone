//
//  ActionElement.m
//  Hoccer
//
//  Created by Philip Brechler on 03.11.11.
//  Copyright (c) 2011 Hoccer GmbH. All rights reserved.
//

#import "ActionElement.h"

@implementation ActionElement

+ (ActionElement *)actionElementWithTarget: (id)aTarget selector: (SEL)aSelector {
	return [[[ActionElement alloc] initWithTargat:aTarget selector:aSelector] autorelease];
}

- (id)initWithTargat: (id)aTarget selector: (SEL)aSelector {
	self = [super init];
	if (self != nil) {
		target = aTarget;
		selector = aSelector;	
	}
	
	return self;
}

- (void)perform {
	[target performSelector:selector];
}

@end
