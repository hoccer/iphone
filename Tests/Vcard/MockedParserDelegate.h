//
//  MockedParserDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 08.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VcardParserDelegate.h"

@interface MockedParserDelegate : NSObject <VcardParserDelegate> {
	NSString *foundProperty;
	NSString *value;
	NSArray  *attributes;
}

@property (copy) NSString* foundProperty;
@property (copy) NSString* value;
@property (retain) NSArray* attributes;

@end
