//
//  HoccerHoclet.m
//  Hoccer
//
//  Created by Robert Palmer on 06.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HoccerHoclet.h"
#import "NSString+StringWithData.h"

@interface HoccerHoclet ()
- (void)injectHocletToWebView: (UIWebView *)view;
@end

@implementation HoccerHoclet

@synthesize webview;
@synthesize view;

- (id)initWithURL: (NSURL *)url {
    return [super initWithData:[[url absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)url {
    NSString *urlString = [NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:urlString];
}


- (UIView *)fullscreenView {
	UIWebView *aWebview = [[UIWebView alloc] initWithFrame: CGRectMake(20, 60, 280, 150)];
	[aWebview loadRequest:[NSURLRequest requestWithURL:[self url]]];
    [self injectHocletToWebView:aWebview];
    
	return [aWebview autorelease];
}

- (Preview *)desktopItemView {
	[[NSBundle mainBundle] loadNibNamed:@"HocletView" owner:self options:nil];
	[webview loadRequest:[NSURLRequest requestWithURL:[self url]]];
    [self injectHocletToWebView:webview];
    
    return self.view;
}

- (void)dealloc {
//	[webview release];	
    [view release];
    
	[super dealloc];
}

- (NSString *)content {
    return [[self url] absoluteString];
}

- (NSString *)mimeType {
	return @"text/x-hoclet";
}

- (NSString *)extension {
	return @"hlt";
}

- (NSString *)defaultFilename {
	return @"Hoclet";
}

- (NSString *)descriptionOfSaveButton {
    return nil;
}

- (BOOL)saveDataToContentStorage {
	return NO;
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

- (void)injectHocletToWebView: (UIWebView *)aView {
    NSString *uuid   = [[NSUserDefaults standardUserDefaults] stringForKey:@"hoccerClientUri"];
    NSString *code = [NSString stringWithFormat: @"hoclet = { getClientId: function() {return '%@'; }}", uuid];
    
	[aView stringByEvaluatingJavaScriptFromString:code];
}

@end
