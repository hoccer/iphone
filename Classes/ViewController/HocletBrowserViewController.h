//
//  HocletBrowserViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 14.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HocletBrowserViewController : UIViewController {
    UIWebView *webView;
    NSURL *url;
    UINavigationItem *navigationItem;
    
    id delgate;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;

- (id)initWithURL: (NSURL *)url;


@end