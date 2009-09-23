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
	
	if (regcomp(&reg, regex, 0) != 0) {
		return NO;
	}
	
	result = regexec(&reg, string, 0, 0, 0);
	regfree(&reg);
	
	return (result == 0) ? YES : NO;
}

@end
