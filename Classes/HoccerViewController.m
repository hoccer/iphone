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
#import "PeerGroupPollingRequest.h"
#import "DownloadRequest.h"

#import "HoccerImage.h"
#import "HoccerUrl.h"

#import "AccelerationRecorder.h"


@implementation HoccerViewController


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

- (void)dealloc {
	[super dealloc];
	
    [statusLabel release];
	[request release];
	[hoccerContent release];
	
	[toolbar release];
}

- (IBAction)onCancel: (id)sender 
{
	[request cancel];
	[request release];
	
	request = nil;
}


- (IBAction)onCatch: (id)sender 
{
	AccelerationRecorder *recorder = [[AccelerationRecorder alloc] init];
	[recorder startRecording];
	[recorder stopRecording];
	[recorder release];
	
	NSLog(@"catched");
	
	if (request != nil) {
		return;
	}
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:52.501077 longitude:13.345116];
	request = [[PeerGroupRequest alloc] initWithLocation: location gesture: @"distribute" andDelegate: self];
}

- (IBAction)saveToGallery: (id)sender 
{
	[hoccerContent save];
}


#pragma mark Communication delegate methods

- (void)finishedRequest: (PeerGroupRequest *)aRequest 
{
	NSLog(@"received peer uri: %@", [aRequest.result valueForKey:@"peer_uri"]);

	HoccerBaseRequest *pollingRequest = [[PeerGroupPollingRequest alloc] initWithObject: aRequest.result andDelegate: self];
	
	[request release];
	request = pollingRequest;
}

- (void)finishedPolling: (PeerGroupPollingRequest *)aRequest 
{
	HoccerBaseRequest *downloadRequest = [[DownloadRequest alloc] initWithObject:aRequest.result delegate:self];
	
	[request release];
	request = downloadRequest;
}

- (void)finishedDownload: (BaseHoccerRequest *)aRequest 
{
	NSString *mimeType = [[aRequest.response allHeaderFields] objectForKey:@"Content-Type"];
	NSLog(@"mime: %@", mimeType);
	
	if ([mimeType rangeOfString:@"image/"].location == 0) {
		hoccerContent = [[HoccerImage alloc] initWithData:aRequest.result];
	} else {
		hoccerContent = [[HoccerUrl alloc] initWithData:aRequest.result];
	}
	
	[self.view insertSubview: hoccerContent.view atIndex:0];
	
	[toolbar setHidden: NO];
	[self.view setNeedsDisplay];

	[request release];
	request = nil;
}


#pragma mark BaseHoccerRequest delegate methods

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	statusLabel.text = [error localizedDescription];
	
	[request release];
	request = nil;
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update 
{
	statusLabel.text = update;
}

@end
