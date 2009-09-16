//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "HoccerViewController.h"
#import "HoccerDownloadRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerContentFactory.h"

@implementation HoccerViewController


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
	[request release];
	
	[hoccerContent release];
	[saveButton release];
	[toolbar release];
    [statusLabel release];

}


- (IBAction)onCancel: (id)sender 
{
	[request cancel];
	[request release];
	
	request = nil;
}


- (IBAction)onCatch: (id)sender 
{
	if (request != nil) {
		return;
	}
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:52.501077 longitude:13.345116];
	request = [[HoccerDownloadRequest alloc] initWithLocation: location gesture: @"distribute" delegate: self];
}

- (IBAction)save: (id)sender 
{
	[hoccerContent save];
}


#pragma mark -
#pragma mark Download Communication Delegate Methods

- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest
{
	hoccerContent = [[HoccerContentFactory createContentFromResponse: aRequest.response 
														   withData: aRequest.result] retain];
	
	[self.view insertSubview: hoccerContent.view atIndex:0];
	saveButton.title = [hoccerContent saveButtonDescription];
	
	[toolbar setHidden: NO];
	[self.view setNeedsDisplay];
	
	[request release];
	request = nil;
}


#pragma mark -
#pragma mark Upload Communication Methods






#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

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
