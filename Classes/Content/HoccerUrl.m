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

- (void) dealloc {
	[webView release];
	[super dealloc];
}

- (void)saveDataToContentStorage 
{
	NSURL *url = nil;
	if (webView) {
		NSURLRequest *request = webView.request;
		url = [request URL];
	} else {
		url = [NSURL URLWithString: self.content];
	}
		
	[[UIApplication sharedApplication] openURL: url];
}

- (NSString *)descriptionOfSaveButton {
	return @"Safari";
}

- (UIView *)fullscreenView {
	webView = [[UIWebView alloc] initWithFrame: CGRectMake(10, 60, 300, 350)];
	webView.scalesPageToFit = YES;
	
	[webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString:self.content]]];	
	return webView;
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_image.png"];
}

@end
