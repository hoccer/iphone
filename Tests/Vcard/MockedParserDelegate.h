//
//  MockedParserDelegate.h
//  Hoccer
//
//  Created by Robert Palmer on 08.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MockedParserDelegate : NSObject {
	NSString *foundProperty;
	NSString *value;
}

@property (copy) NSString* foundProperty;
@property (copy) NSString* value;

@end
