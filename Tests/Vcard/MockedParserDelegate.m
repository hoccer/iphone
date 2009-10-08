//
//  MockedParserDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 08.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "MockedParserDelegate.h"
#import "VcardParser.h"


@implementation MockedParserDelegate

@synthesize foundProperty;


- (void)parserDidFoundProperty: (NSString *)property
	 withValue: (NSString *)value attributes: (NSArray *)attributes
{
	self.foundProperty = property;
}


- (void)parser: (VcardParser *)parser didFoundFormattedName: (NSString *)name 
{
	self.foundProperty = @"FN";
}

- (void)parser: (VcardParser *)parser didFoundPhoneNumber: (NSString *)number 
										   withAttributes: (NSArray *) attributes
{
	self.foundProperty = @"TEL";
};



@end
