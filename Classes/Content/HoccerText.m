//
//  HoccerText.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerText.h"


@implementation HoccerText

- (id) initWithData: (NSData *)data {
	self = [super init];
	
	if (self != nil) {
		content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	
	return self;
}

- (void)save {}

- (void)dismiss {}

- (UIView *)view {
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 300, 20)];
	label.text = content;
	
	return label;
}


- (NSString *)saveButtonDescription 
{
	return @"OK";
}
	
- (void)dealloc
{
	[content release];

	[super dealloc];
}


- (NSString *)filename 
{
	return @"text.txt";
}

- (NSString *)mimeType
{
	return @"tex/plain";
}

- (NSData *)data 
{
	return [content dataUsingEncoding: NSUTF8StringEncoding];
}




@end
