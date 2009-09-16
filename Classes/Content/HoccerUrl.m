//
//  UrlContent.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerUrl.h"

@implementation HoccerUrl

+ (BOOL)isDataAUrl: (NSData *)data
{
	NSString *url = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	if (![NSURL URLWithString: url] || [url rangeOfString:@"http"].location != 0) {
		return NO;
	}
	
	return YES;
}

- (void)save 
{
	NSLog(@"opening: %@", content);
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: content]];
}

- (void)dismiss {}

- (NSString *)saveButtonDescription 
{
	return @"Open in Safari";
}

@end
