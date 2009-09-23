//
//  NSObject+Regexp.m
//  Hoccer
//
//  Created by Robert Palmer on 23.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "NSString+Regexp.h"
#import <regex.h>

@implementation NSString (Regexp)

- (BOOL)matches: (NSString *)pattern 
{
	int result;
	regex_t reg;
	
	const char* regex = [pattern UTF8String];
	const char* string = [self UTF8String];
	
	if (regcomp(&reg, regex, REG_EXTENDED | REG_NOSUB) != 0) {
		return NO;
	}
	
	result = regexec(&reg, string, 0, 0, 0);
	regfree(&reg);
	
	return (result == 0) ? YES : NO;
}

- (BOOL)matchesFeaturePattern: (NSString *)featurePattern
{
	NSMutableString *string = [NSMutableString stringWithString: featurePattern];

	[string replaceOccurrencesOfString:@"<*" withString:@"<[a-zA-Z]*"
							   options:0 range:NSMakeRange(0, [string length])];
	
	[string replaceOccurrencesOfString:@"*>" withString:@"[a-zA-Z]*>"
							   options:0 range:NSMakeRange(0, [string length])];
	
	[string replaceOccurrencesOfString:@">*<" withString:@">.+<"
							   options:0 range:NSMakeRange(0, [string length])];
	
	[string replaceOccurrencesOfString:@"*<" withString:@".+<"
							   options:0 range:NSMakeRange(0, [string length])];

	[string replaceOccurrencesOfString:@">*" withString:@">.+"
							   options:0 range:NSMakeRange(0, [string length])];

	return [self matches: string];
}



@end
