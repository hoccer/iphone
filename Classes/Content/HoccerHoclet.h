//
//  HoccerHoclet.h
//  Hoccer
//
//  Created by Robert Palmer on 06.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoccerContent.h"

@interface HoccerHoclet : HoccerContent {
    UIWebView *webview;
    Preview *view;
}

@property (nonatomic, readonly) NSString *content;
@property (retain, nonatomic) IBOutlet UIWebView *webview;
@property (retain, nonatomic) IBOutlet Preview *view;

- (id)initWithURL: (NSURL *)url;
- (NSURL *)url;

@end
