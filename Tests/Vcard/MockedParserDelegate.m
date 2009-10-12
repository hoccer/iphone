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
@synthesize value;
@synthesize attributes;

- (void)parserDidFoundProperty: (NSString *)property
	 withValue: (NSString *)value attributes: (NSArray *)attributes
{
	self.foundProperty = property;
}


- (void)parser: (VcardParser *)parser didFoundFormattedName: (NSString *)name 
{
	self.foundProperty = @"FN";
	self.value = name;
	self.attributes = attributes;
}

- (void)parser: (VcardParser *)parser didFoundPhoneNumber: (NSString *)number 
										   withAttributes: (NSArray *) theAttributes
{
	self.foundProperty = @"TEL";
	self.value = number;
	self.attributes = attributes;
}

- (void)parser: (VcardParser *)parser didFoundEmail: (NSString *)email
									 withAttributes: (NSArray *) theAttributes 
{
	self.foundProperty = @"EMAIL";
	self.value = email;
	self.attributes = theAttributes;
}

- (void)parser: (VcardParser *)parser didFoundAddress: (NSString *)email
withAttributes: (NSArray *) theAttributes 
{
	self.foundProperty = @"ADR";
	self.attributes = theAttributes;
}

@end
