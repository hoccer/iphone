//
//  UrlContent.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerUrl.h"


@implementation HoccerUrl


+ (BOOL) isDataAUrl: (NSData *)data
{
	NSString *url = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if ([NSURL URLWithString: url]) {
		return YES;
	} else {
		return NO;
	}
	
	
}

- (id)initWithData: (NSData *)data 
{
	self = [super init];
	
	if (self != nil) {
		url = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	
	return self;
}


- (void)save 
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}


- (void)dismiss {}


- (UIView *)view 
{
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 300, 20)];
	label.text = url;
	
	return label;
}

- (NSString *)saveButtonDescription 
{
	return @"Open in Safari";
}


- (void)dealloc
{
	[super dealloc];
	[url release];
}

@end
