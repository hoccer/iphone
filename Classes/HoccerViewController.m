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
#import "HoccerUploadRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerContentFactory.h"

@interface HoccerViewController (Private)

- (CLLocation *)currentLocation;

@end



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
	[request release];
	
	[hoccerContent release];
	[saveButton release];
	[toolbar release];
    [statusLabel release];

	[super dealloc];
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
	
	CLLocation *location = [self currentLocation];
	request = [[HoccerDownloadRequest alloc] initWithLocation: location gesture: @"distribute" delegate: self];
}


- (void)onThrow: (id)sender 
{
	if (request != nil) {
		return;
	}
	
	CLLocation *location = [self currentLocation];

	NSString *type = @"type";
	NSString *filename = @"text.txt";
	NSData *data = [[NSString stringWithString:@"http://www.artcom.de"] dataUsingEncoding: NSUTF8StringEncoding];
	
	
	request = [[HoccerUploadRequest alloc] initWithLocation:location gesture:@"distribute" data: data 
													   type: type filename: filename delegate:self];
}

- (IBAction)save: (id)sender 
{
	[hoccerContent save];
}


- (CLLocation *) currentLocation
{
	return [[CLLocation alloc] initWithLatitude:52.501077 longitude:13.345116];
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
#pragma mark Upload Communication 

- (void)requestDidFinishUpload: (BaseHoccerRequest *)aRequest
{
	[request release];
	request = nil;
	
	NSLog(@"finished upload");
}



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
