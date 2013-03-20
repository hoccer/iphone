//
//  HoccerText.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "HoccerText.h"

#import "Preview.h"
#import "NSString+StringWithData.h"

@implementation HoccerText

@synthesize textView;
@synthesize view;


+ (BOOL)isDataAUrl: (NSData *)data {
	NSString *url = [[NSString stringWithData:data usingEncoding:NSUTF8StringEncoding] lowercaseString];
	
	if (![NSURL URLWithString: url] || [url rangeOfString:@"http"].location != 0) {
		return NO;
	}
	return YES;
}



- (UIView *)fullscreenView {
    
    CGRect screenRect;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        screenRect = [[UIScreen mainScreen] bounds];
        screenRect.size.height = screenRect.size.height - (20+44+48);
    }
    else {
        screenRect = CGRectMake(0, 0, 320, 367);
    }

	UITextView *text = [[UITextView alloc] initWithFrame: screenRect];
	text.text = self.content;
    text.font = [UIFont systemFontOfSize:16];
    text.textColor = [UIColor blackColor];
	text.editable = NO;
	
	return [text autorelease];
}


- (Preview *)desktopItemView {
    
	[[NSBundle mainBundle] loadNibNamed:@"TextView" owner:self options:nil];
    
    [self.editButton setTitle:NSLocalizedString(@"Button_Edit", nil) forState:UIControlStateNormal];
    
	self.view.delegate = self;	
	if (!self.data || [self.data length] == 0) {
		[self.view showTextInputView:nil];
	} else {
		self.view.textView.text = self.content;
	}
	
	return self.view;
}
	
- (void)dealloc {
    [view release];
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
   
	return NSLocalizedString(@"DefaultFilename_Text", nil);
}

- (NSString *)descriptionOfSaveButton {
	if ([HoccerText isDataAUrl: self.data]) {
		return NSLocalizedString(@"Button_Safari", nil);
	} else {
		return NSLocalizedString(@"Button_Copy", nil);
	}
}

- (void)dismissKeyboard {
	[textView resignFirstResponder];
}

- (NSString *)content {
	return [NSString stringWithData:super.data usingEncoding:NSUTF8StringEncoding];
}

- (BOOL)saveDataToContentStorage {
	if ([HoccerText isDataAUrl: self.data]) {
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString:self.content]];
	} else {
		[UIPasteboard generalPasteboard].string = [self content];
	}
	
	return YES;
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

- (NSDictionary *)dataDesctiption {
	NSString *oldString = [NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding];

	if (![oldString isEqual:self.view.textView.text]) {
		self.data = [self.view.textView.text dataUsingEncoding:NSUTF8StringEncoding];
		[self saveDataToDocumentDirectory];
	}	
	
    NSString *crypted = [self.cryptor encryptString:self.view.textView.text];
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
	[dictionary setObject:crypted forKey:@"content"];
	
	if ([HoccerText isDataAUrl:self.data]) {
		[dictionary setObject:@"text/uri-list" forKey:@"type"];
	} else {
		[dictionary setObject:@"text/plain" forKey:@"type"];
	}
    
    [self.cryptor appendInfoToDictionary:dictionary];
	return dictionary;
}

@end
