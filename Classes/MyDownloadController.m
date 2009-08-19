//
//  MyDownloadController.m
//  UITest
//
//  Created by david on 18.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyDownloadController.h"


@implementation MyDownloadController

@synthesize delegate;

- (void) fetchURL:(NSURL*) theURL {
	if (receivedData) {
		NSLog(@"Kaputt: Another request is still in progress");
	}
	
	
	NSMutableURLRequest * request = [NSURLRequest requestWithURL: theURL
										   cachePolicy:NSURLRequestUseProtocolCachePolicy
										   timeoutInterval:60.0];

	NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
	if (connection) {
		receivedData = [[NSMutableData data] retain];
	} else {
		NSLog(@"Kaputt: Failed to create connection");
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"didReceiveResponde");
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	if (delegate != nil) {
		[delegate onError: error];
	} else {
		NSLog(@"Kaputt: No DownloadControllerDelegate");
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	if (delegate != nil) {
		[delegate onDownloadDone: receivedData];
	} else {
		NSLog(@"Kaputt: No DownloadControllerDelegate");
	}
	
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}
@end
