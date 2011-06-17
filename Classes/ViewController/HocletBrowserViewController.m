//
//  HocletBrowserViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 14.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HocletBrowserViewController.h"

@implementation HocletBrowserViewController
@synthesize navigationItem;
@synthesize webView;
@synthesize delegate;

- (id)initWithURL: (NSURL *)aUrl {
    self = [super initWithNibName: @"HocletBrowserViewController" bundle:nil];
    if (self) {
        url = [aUrl retain];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setNavigationItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [url release];
    [webView release];
    [navigationItem release];
    [super dealloc];
}

- (void)close: (id)sender {
    if ([delegate respondsToSelector:@selector(closeHocletBrowser:)]) {
        [delegate performSelector:@selector(closeHocletBrowser:) withObject:self];
    }
}

@end

