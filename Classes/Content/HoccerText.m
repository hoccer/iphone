//
//  HoccerText.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerText.h"
#import "PreviewView.h"

@interface HoccerText ()

@property (retain) UITextView* textView;

@end



@implementation HoccerText

@synthesize textView;

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
	UITextView *label = [[UITextView alloc] initWithFrame: CGRectMake(10, 50, 270, 60)];
	label.text = content;
	label.editable = YES;
	
	return [label autorelease];
}

-  (PreviewView *)preview 
{
	PreviewView *view = [[PreviewView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];	
	self.textView =  [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 165, 165)];
	[view insertSubview: textView atIndex: 0];
	
	return [view autorelease];
}


- (NSString *)saveButtonDescription 
{
	return nil;
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

- (BOOL)isDataReady 
{
	return YES;
}

- (void) contentWillBeDismissed 
{
	[textView resignFirstResponder];
}


- (void)dismissKeyboard
{
	[textView resignFirstResponder];
}

@end
