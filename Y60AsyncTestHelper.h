//
//  Y60AsyncTestHelper.h
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Y60AsyncTestHelper : NSObject {

}

+ (BOOL)waitForTarget: (id)target selector: (SEL)selector toBecome: (NSInteger)value atLeast: (NSTimeInterval)seconds;

@end
