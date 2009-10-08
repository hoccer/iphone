//
//  VcardParser.m
//  Hoccer
//
//  Created by Robert Palmer on 08.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "VcardParser.h"


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
		
		
		[delegate parser: self didFoundFormattedName: @"Robert Palmer"];
 
	}
}


@end
