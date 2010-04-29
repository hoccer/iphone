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
@synthesize view;

- (UIView *)fullscreenView {
	UITextView *text = [[UITextView alloc] initWithFrame: CGRectMake(20, 60, 280, 150)];
	text.text = self.content;
	text.editable = YES;
	
	return [text autorelease];
}

- (Preview *)desktopItemView {
	[[NSBundle mainBundle] loadNibNamed:@"TextView" owner:self options:nil];
	
	return self.view;
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
