//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "HoccerViewController.h"

#import <CoreLocation/CoreLocation.h>
#import "PeerGroupRequest.h"

@implementation HoccerViewController
@synthesize catchButton;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (IBAction)onCatch: (id)sender {
	NSLog(@"catched");
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:52.121312 longitude:14.1123123];
	request = [[PeerGroupRequest alloc] initWithLocation: location gesture: @"distribute" andDelegate: self];
}

- (void)finishedRequest: (PeerGroupRequest *)aRequest {
	NSLog(@"request abgeschlossen");
	
	NSLog(@"received peer uri: %@", [aRequest.result valueForKey:@"peer_uri"]);
}

- (void)dealloc {
    [catchButton release];
	[super dealloc];
}

@end
