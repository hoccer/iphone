//
//  VcardParser.m
//  Hoccer
//
//  Created by Robert Palmer on 08.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "VcardParser.h"


@implementation VcardParser

- (id)initWithString: (NSString *)vcard
{
	self = [super init];
	if (self != nil) {
		vcardLines = [vcard componentsSeparatedByString:@"\r\n"];
	}
	return self;
}


- (BOOL)isValidVcard
{
	return [[vcardLines objectAtIndex:0] isEqual: @"BEGIN:VCARD"] && 
				[[vcardLines objectAtIndex:1] isEqual: @"VERSION:3.0"] &&
				[[vcardLines lastObject] isEqual: @"END:VCARD"];
}

- (void)parse
{
	
}


@end
