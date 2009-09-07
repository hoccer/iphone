//
//  NSObject+DelegateHelper.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSObject+DelegateHelper.h"


@implementation NSObject (DelegateHelper)

- (BOOL)checkAndPerformSelector: (SEL)aSelector  {
	if (![self respondsToSelector:aSelector]) {
		return NO;
	}
	
	[self performSelector:aSelector];
	return YES;
}

- (BOOL)checkAndPerformSelector: (SEL)aSelector withObject: (id)aObject  {
	if (![self respondsToSelector:aSelector]) {
		return NO;
	}
	
	[self performSelector:aSelector withObject:aObject];
	return YES;
}



@end
