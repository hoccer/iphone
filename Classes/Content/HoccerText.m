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
	
	self.view.delegate = self;
	if (!self.data) {
		[self.view setEditMode];
	} else {
		self.view.textView.text = self.content;
	}
	
	return self.view;
}
	
- (void)dealloc {
	[textView release];	
	[super dealloc];
}

- (void)prepareSharing {
	self.data = [self.view.textView.text dataUsingEncoding: NSUTF8StringEncoding];
	[self.data writeToFile: filepath atomically: NO];
}

- (NSString *)mimeType {
	return @"text/plain";
}

- (NSString *)extension {
	return @"txt";
}

- (void)dismissKeyboard
{
	[textView resignFirstResponder];
}

- (NSString *)content {
	return [NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding];
}

- (void)textPreviewDidEndEditing: (TextPreview *)preview {
	self.data = [self.view.textView.text dataUsingEncoding: NSUTF8StringEncoding];
}

- (void)saveDataToContentStorage {
	[UIPasteboard generalPasteboard].string = [self content];
}

- (UIImage *)imageForSaveButton {
	return [UIImage imageNamed:@"container_btn_double-copy.png"];
}


@end
