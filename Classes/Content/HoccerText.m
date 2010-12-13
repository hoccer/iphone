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
	NSLog(@"super data: %@", super.data);
	
	if (!super.data || [super.data length] == 0) {
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

- (NSString *)mimeType {
	return @"text/plain";
}

- (NSString *)extension {
	return @"txt";
}

- (NSString *)defaultFilename {
	return @"Message";
}

- (NSString *)descriptionOfSaveButton {
	if ([HoccerText isDataAUrl: self.data]) {
		return NSLocalizedString(@"Safari", nil);
	} else {
		return NSLocalizedString(@"Copy", nil);
	}
}

- (void)dismissKeyboard {
	[textView resignFirstResponder];
}

- (NSString *)content {
	return [NSString stringWithData:super.data usingEncoding:NSUTF8StringEncoding];
}

//- (NSData *)data {
//	return [self.view.textView.text dataUsingEncoding: NSUTF8StringEncoding];
//}

- (BOOL)saveDataToContentStorage {
	if ([HoccerText isDataAUrl: self.data]) {
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString:self.content]];
	} else {
		[UIPasteboard generalPasteboard].string = [self content];
	}
	
	return YES;

}

- (UIImage *)imageForSaveButton {
	if ([HoccerText isDataAUrl: super.data]) {
		return [UIImage imageNamed:@"container_btn_double-safari.png"];
	} else {
		return [UIImage imageNamed:@"container_btn_double-copy.png"];
	}
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_text.png"];
}

- (NSDictionary *)dataDesctiption {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:self.view.textView.text forKey:@"content"];
	[dictionary setObject:@"text/plain" forKey:@"type"];
	
	return dictionary;
}

@end
