//
//  UrlContent.h
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "HoccerContent.h"
#import "HoccerText.h"

@interface HoccerUrl : HoccerText {
	UIWebView  *webView;
}

+ (BOOL) isDataAUrl: (NSData *)data;


@end
