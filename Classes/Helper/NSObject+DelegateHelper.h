//
//  NSObject+DelegateHelper.h
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (DelegateHelper)

- (BOOL)checkAndPerformSelector: (SEL)selector;
- (BOOL)checkAndPerformSelector: (SEL)aSelector withObject: (id)aObject;
- (BOOL)checkAndPerformSelector: (SEL)aSelector withObject: (id)firstObject withObject: (id)secondObject;

@end
