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
	UITextView *text = [[UITextView alloc] initWithFrame: CGRectMake(20, 60, 280, 150)];
	text.text = content;
	text.editable = YES;
	
	return [text autorelease];
}

- (PreviewView *)previewWithFrame: (CGRect)frame
{
	PreviewView *view = [[PreviewView alloc] initWithFrame:frame];	

	self.textView =  [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 155, 155)];
	[view insertSubview: textView atIndex: 0];
	[self.textView becomeFirstResponder];
	
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

- (BOOL)needsWaiting 
{
	return NO;
}

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector 
{}

@end
