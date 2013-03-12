//
//  HelpOverview.m
//  Hoccer
//
//  Created by Robert Palmer on 10.11.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "HelpOverview.h"


@implementation HelpOverview
@synthesize textView;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.text = NSLocalizedString(@"HelpIntro", nil);
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
