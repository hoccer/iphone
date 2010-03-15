//
//  UrlContent.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerUrl.h"

@implementation HoccerUrl

+ (BOOL)isDataAUrl: (NSData *)data
{
	NSString *url = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	if (![NSURL URLWithString: url] || [url rangeOfString:@"http"].location != 0) {
		return NO;
	}
	
	return YES;
}

- (void)save 
{
	NSURL *url = nil;
	if (webView) {
		NSURLRequest *request = webView.request;
		url = [request URL];
	} else {
		url = [NSURL URLWithString: content];
	}
		
	[[UIApplication sharedApplication] openURL: url];
}

- (void)dismiss {}

- (NSString *)saveButtonDescription 
{
	return @"Open in Safari";
}

- (UIView *)view {
	webView = [[UIWebView alloc] initWithFrame: CGRectMake(10, 60, 300, 350)];
	webView.scalesPageToFit = YES;
	
	[webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString:content]]];	
	return [webView  autorelease];
}

- (PreviewView *)preview
{
	return nil;
}

- (void)contentWillBeDismissed 
{
}

- (BOOL)needsWaiting 
{
	return NO;
}

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector 
{}


@end
