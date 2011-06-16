//
//  HoccerHoclet.m
//  Hoccer
//
//  Created by Robert Palmer on 06.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HoccerHoclet.h"
#import "NSString+StringWithData.h"
#import "HocletBrowserViewController.h"

@interface HoccerHoclet ()
- (void)injectHocletToWebView: (UIWebView *)view;
- (void)setCookie;
@end

@implementation HoccerHoclet

@synthesize webview;
@synthesize view;

- (id)initWithURL: (NSURL *)url {
    return [self initWithData:[[url absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)url {
    NSString *urlString = [NSString stringWithData:self.data usingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:urlString];
}


- (UIView *)fullscreenView {
	UIWebView *aWebview = [[UIWebView alloc] initWithFrame: CGRectMake(20, 60, 280, 150)];
	
    [self setCookie];
    [aWebview loadRequest:[NSURLRequest requestWithURL:[self url]]];
    [self injectHocletToWebView:aWebview];
    
	return [aWebview autorelease];
}

- (Preview *)desktopItemView {
    [self setCookie];
    
	[[NSBundle mainBundle] loadNibNamed:@"HocletView" owner:self options:nil];
	[webview loadRequest:[NSURLRequest requestWithURL:[self url]]];
    [self injectHocletToWebView:webview];
    
    return self.view;
}

- (void)dealloc {
//	[webview release];	
    [view release];
    [controller release];
    
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
    return NSLocalizedString(@"Show", nil);
}

- (BOOL)saveDataToContentStorage {
	return NO;
}

- (UIImage *)imageForSaveButton {
	return [UIImage imageNamed:@"container_btn_double-save.png"];
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
    NSString *js = [NSString stringWithFormat: @"hoclet = { getClientId: function() {return '%@'; }}", uuid];
    
	[aView stringByEvaluatingJavaScriptFromString:js];
}

- (BOOL)presentOpenInViewController:(UIViewController *)aController {
    controller = [aController retain];
    
    HocletBrowserViewController *viewController = [[HocletBrowserViewController alloc] initWithURL:[self url]];
    [controller presentModalViewController:viewController animated:YES];
    
    [self injectHocletToWebView:viewController.webView];
    viewController.delegate = self;
    
    return YES;
}

- (void)closeHocletBrowser: (HocletBrowserViewController *)hocletBrowser {
    [controller dismissModalViewControllerAnimated:YES];

    [controller release];
    controller = nil;
}

- (void)setCookie {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    NSString *uuid   = [[NSUserDefaults standardUserDefaults] stringForKey:@"hoccerClientUri"];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"client" forKey:NSHTTPCookieName];
    [cookieProperties setObject:uuid forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"hoclet-experimental.hoccer.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];  
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie: cookie];
}

@end
