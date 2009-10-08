//
//  VcardParser.h
//  Hoccer
//
//  Created by Robert Palmer on 08.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VcardParser : NSObject {
	NSArray *vcardLines;
}

- (id)initWithString: (NSString *)vcard;
- (BOOL)isValidVcard;

@end
