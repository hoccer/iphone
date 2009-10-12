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

- (UIView *)view 
{
	UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10, 50, 300, 20)];
	label.text = content;
	
	return [label autorelease];
}

-  (UIView *)preview 
{
	textView =  [[UITextView alloc] initWithFrame:CGRectMake(10, 50, 300, 60)];
	textView.delegate = self;
	
	return [textView autorelease];
}

- (NSString *)saveButtonDescription 
{
	return @"OK";
}
	
- (void)dealloc
{
	[textView release];
	[content release];
	[super dealloc];
}


- (NSString *)filename 
{
	return @"text.txt";
}

- (NSString *)mimeType
{
	return @"text/plain";
}

- (NSData *)data 
{
	[textView resignFirstResponder];
	return [textView.text dataUsingEncoding: NSUTF8StringEncoding];
}

- (BOOL)isDataReady {
	return YES;
}


@end
