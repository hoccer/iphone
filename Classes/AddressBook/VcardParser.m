//
//  VcardParser.m
//  Hoccer
//
//  Created by Robert Palmer on 08.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "VcardParser.h"
#import "NSString+Regexp.h"

@interface VcardParser (Private) 

- (NSArray *)attributesFromString: (NSString *) string;

@end



@implementation VcardParser


@synthesize delegate;

- (id)initWithString: (NSString *)vcard
{
	self = [super init];
	if (self != nil) {
		vcardLines = [[vcard componentsSeparatedByString:@"\r\n"] retain];
	}
	return self;
}

- (void) dealloc
{
	[vcardLines release];
	[super dealloc];
}

- (BOOL)isValidVcard
{
	if ([vcardLines count] < 2)
		return NO;
	
	return [[vcardLines objectAtIndex:0] isEqual: @"BEGIN:VCARD"] && 
				[[vcardLines objectAtIndex:1] isEqual: @"VERSION:3.0"] &&
				[[vcardLines lastObject] isEqual: @"END:VCARD"];
}

- (void)parse
{
	for (int i = 2; i < [vcardLines count]; i++) {
		NSArray *propertyWithAttributesAndValue = [[vcardLines objectAtIndex:i] 
												   componentsSeparatedByString: @":"];
		NSString *propertyWithAttributes = [propertyWithAttributesAndValue objectAtIndex:0];
		NSArray *propertyAndAttributes = [propertyWithAttributes componentsSeparatedByString: @";"];
		
		NSString *attributs = nil;
		NSString *value = [propertyWithAttributesAndValue objectAtIndex:1];
		NSString *property = [propertyAndAttributes objectAtIndex:0];
		
		if ([propertyAndAttributes count] > 1) {
			attributs = [propertyAndAttributes objectAtIndex:1];
		}
		
		if ([property isEqual: @"FN"]) {
			[delegate parser: self didFoundFormattedName: value];
		} else if ([property isEqual: @"TEL"]) {
			[delegate parser: self didFoundPhoneNumber: value 
			  withAttributes: [self attributesFromString: attributs]];
		} else if ([property isEqual: @"EMAIL"]) {
			[delegate parser: self didFoundEmail: value 
			  withAttributes: [self attributesFromString: attributs]];
		} else if ([property isEqual: @"ADR"]) {
			[delegate parser: self didFoundAddress: value 
			  withAttributes: [self attributesFromString: attributs]];
			
			NSLog(@"attributes in %s: %@", _cmd, [self attributesFromString: attributs]);
		}
	}
}

- (NSArray *)attributesFromString: (NSString *) string
{
	if (!string)
		return nil;
	
	NSArray *attributs = nil;
	
	if ([string contains:@","]) {
		attributs = [string componentsSeparatedByString:@","];
	} else if ([string contains:@";"]) {
		attributs = [string componentsSeparatedByString:@";"];
	} else {
		attributs = [NSArray arrayWithObject: string];
	}		
	
	NSMutableArray *mutableAttributes = [NSMutableArray arrayWithArray:attributs];
	for (int i = 0; i < [attributs count]; i++) {
		if ([[mutableAttributes objectAtIndex:i] startsWith: @"TYPE="]) {
			NSString *attributString = [mutableAttributes objectAtIndex:i];
			
			[mutableAttributes replaceObjectAtIndex:i 
										 withObject: [attributString substringFromIndex:5]];
		}
	}
	
	return mutableAttributes;
}

@end
