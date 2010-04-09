//
//  HoccerText.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerText.h"

#import "Preview.h"
#import "NSString+StringWithData.h"

@interface HoccerText ()

@property (retain) UITextView* textView;

@end

@implementation HoccerText

@synthesize textView;

- (UIView *)fullscreenView {
	UITextView *text = [[UITextView alloc] initWithFrame: CGRectMake(20, 60, 280, 150)];
	text.text = self.content;
	text.editable = YES;
	
	return [text autorelease];
}

- (Preview *)desktopItemView {
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 319, 234)];
	
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Photobox" ofType:@"png"];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImagePath]];
	
	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
		
	self.textView =  [[[UITextView alloc] initWithFrame:CGRectMake(40, 45, 240, 170)] autorelease];
	self.textView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
	self.textView.font = [UIFont systemFontOfSize: [UIFont systemFontSize] + 2];
	
	if (self.data != nil) {
		self.textView.text = [NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding];
	}
	
	[view insertSubview: textView atIndex: 1];
	[self.textView becomeFirstResponder];
	
	[backgroundImage release];
	return [view autorelease];
}
	
- (void)dealloc
{
	[textView release];	
	[super dealloc];
}

- (void)prepareSharing{
	[self.data writeToFile: filepath atomically: NO];
}

- (NSString *)mimeType
{
	return @"text/plain";
}

- (NSString *)extension {
	return @"txt";
}

- (NSData *)data 
{	
	[textView resignFirstResponder];
	return [textView.text dataUsingEncoding: NSUTF8StringEncoding];
}

- (void)dismissKeyboard
{
	[textView resignFirstResponder];
}

- (NSString *)content {
	return [NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding];
}

@end
