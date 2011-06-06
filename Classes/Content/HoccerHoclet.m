//
//  HoccerHoclet.m
//  Hoccer
//
//  Created by Robert Palmer on 06.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HoccerHoclet.h"
#import "NSString+StringWithData.h"

@implementation HoccerHoclet

@synthesize webview;
@synthesize view;

- (id)initWithURL: (NSString *)url {
    self = [super init];
    if (self != nil) {
        URL = [url retain];
    }
    
    return self;
}

- (id) initWithDictionary: (NSDictionary *)dict {
    self = [super init];
    if (self != nil) {
        if ([dict objectForKey:@"content"]) {
            URL = [NSURL URLWithString:[dict objectForKey:@"content"]];
        }
    }
    
    return self;
}

- (UIView *)fullscreenView {
	UITextView *text = [[UITextView alloc] initWithFrame: CGRectMake(20, 60, 280, 150)];
	text.text = self.content;
	text.editable = YES;
	
	return [text autorelease];
}

- (Preview *)desktopItemView {
	[[NSBundle mainBundle] loadNibNamed:@"HocletView" owner:self options:nil];
	[webview loadRequest:[NSURLRequest requestWithURL:URL]];
    
    NSString *uuid   = [[NSUserDefaults standardUserDefaults] stringForKey:@"hoccerClientUri"];
    NSString *code = [NSString stringWithFormat: @"hoclet = { getClientId: function() {return '%@'; }}", uuid];

	[webview stringByEvaluatingJavaScriptFromString:code];

    return self.view;
}

- (void)dealloc {
//	[webview release];	
    [view release];
    [URL release];
    
	[super dealloc];
}

- (NSString *)content {
    return [URL absoluteString];
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
    return nil;
}

- (BOOL)saveDataToContentStorage {
	
	return YES;
}

- (UIImage *)imageForSaveButton {
    return nil;
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_text.png"];
}

- (NSDictionary *)dataDesctiption {
	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:self.content forKey:@"content"];
	[dictionary setObject:@"text/x-hoclet" forKey:@"type"];
    
	return dictionary;
}

@end
