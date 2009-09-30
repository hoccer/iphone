//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "HoccerAppDelegate.h"
#import "HoccerViewController.h"
#import "ReceivedContentView.h"

#import "BaseHoccerRequest.h"

#import "HoccerDownloadRequest.h"
#import "HoccerUploadRequest.h"
#import "GesturesInterpreter.h"

#import "HoccerContentFactory.h"
#import "HoccerImage.h"

@implementation HoccerAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize contentToSend;
@synthesize hoccerContent;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];

	gesturesInterpreter = [[GesturesInterpreter alloc] init];
	gesturesInterpreter.delegate = self;
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager startUpdatingLocation];

	[request release];

	// Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[locationManager stopUpdatingLocation];
	[locationManager release];
	locationManager = nil;
	
	[hoccerContent release];
	[contentToSend release];
	[request release];
	
    [viewController release];
    [window release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)aViewController
{
	NSLog(@"selected class: %@", aViewController);
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.contentToSend = [[[HoccerImage alloc] initWithUIImage:[info objectForKey: UIImagePickerControllerOriginalImage]] autorelease] ;
	
	[hoccerViewController setContentPreview: self.contentToSend];
	viewController.selectedViewController = hoccerViewController;
	
}

#pragma mark -
#pragma mark GesturesInterpreter Delegate Methods

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter
{
	NSLog(@"im catching, wooo");
	
	if (request != nil) {
		return;
	}
	
	CLLocation *location = [self currentLocation];
	request = [[HoccerDownloadRequest alloc] initWithLocation: location gesture: @"distribute" delegate: self];
}


- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter
{
	NSLog(@"im throwing, wooo");
	
	if (request != nil) {
		return;
	}
	
	[hoccerViewController setUpdate: @"preparing"];
	
	CLLocation *location = [self currentLocation];
	request = [[HoccerUploadRequest alloc] initWithLocation:location gesture:@"distribute" data: [contentToSend data] 
													   type: [contentToSend mimeType] filename: [contentToSend filename] delegate:self];
}


#pragma mark -
#pragma mark Download Communication Delegate Methods

- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest
{
	NSLog(@"request did finish, showing picture");
	
	self.hoccerContent = [HoccerContentFactory createContentFromResponse: aRequest.response 
														    withData: aRequest.result];
	
	receivedContentView = [[[ReceivedContentView alloc] initWithNibName:@"ReceivedContentView" bundle:nil] autorelease];
	
	receivedContentView.delegate = self;
	[receivedContentView setHoccerContent: self.hoccerContent];
	
	
	[viewController presentModalViewController: receivedContentView animated:YES];

	[request release];
	request = nil;
}


#pragma mark -
#pragma mark Upload Communication 

- (void)requestDidFinishUpload: (BaseHoccerRequest *)aRequest
{
	[request release];
	request = nil;
}


#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	[hoccerViewController setUpdate: [error localizedDescription]];
	
	[request release];
	request = nil;
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update 
{
	[hoccerViewController setUpdate: update];
}

- (CLLocation *) currentLocation
{
	return [[[CLLocation alloc] initWithLatitude:52.501077 longitude:13.345116] autorelease];
//	return locationManager.location;
}

#pragma mark -
#pragma mark Reverse Geocoding Methods

- (void)updateLocation
{
	MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate: [self currentLocation].coordinate];
	geocoder.delegate = self;
	
	[geocoder start];
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	[geocoder release];
	CLLocation *location = [self currentLocation];
	
	[hoccerViewController setLocation:placemark withAccuracy: location.horizontalAccuracy];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError: (NSError *)error
{
}

#pragma mark -
#pragma mark Interaction Delegate Methods

- (void)userDidCancelRequest
{
	[request cancel];
	[request release];
	
	request = nil;
}


- (void)userDidSaveContent
{
	NSLog(@"save");
	
	[hoccerContent saveWithSelector: @selector(image:didFinishSavingWithError:contextInfo:) target: self];
}


- (void)userDidDismissContent
{
	[viewController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Saving Delegate Methods

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	NSLog(@"did save: error: %@", error);

	[viewController dismissModalViewControllerAnimated:YES];
}

@end
