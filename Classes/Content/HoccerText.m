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


+ (BOOL)isDataAUrl: (NSData *)data {
	NSString *url = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	if (![NSURL URLWithString: url] || [url rangeOfString:@"http"].location != 0) {
		return NO;
	}
	
	return YES;
}

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
	[self.data writeToFile: self.filepath atomically: NO];
}

- (NSString *)mimeType {
	return @"text/plain";
}

- (NSString *)extension {
	return @"txt";
}

- (NSString *)defaultFilename {
	return @"Message";
}

- (void)dismissKeyboard {
	[textView resignFirstResponder];
}

- (NSString *)content {
	return [NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding];
}

- (void)textPreviewDidEndEditing: (TextPreview *)preview {
	self.data = [self.view.textView.text dataUsingEncoding: NSUTF8StringEncoding];
}

- (void)saveDataToContentStorage {
	if ([HoccerText isDataAUrl: self.data]) {
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString:self.content]];
	} else {
		[UIPasteboard generalPasteboard].string = [self content];
	}

}

- (UIImage *)imageForSaveButton {
	if ([HoccerText isDataAUrl: self.data]) {
		return [UIImage imageNamed:@"container_btn_double-safari.png"];
	} else {
		return [UIImage imageNamed:@"container_btn_double-copy.png"];
	}
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_text.png"];
}


@end
