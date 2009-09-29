//
//  HoccerAppDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "HoccerAppDelegate.h"
#import "HoccerViewController.h"

#import "BaseHoccerRequest.h"

#import "HoccerDownloadRequest.h"
#import "HoccerUploadRequest.h"
#import "GesturesInterpreter.h"

#import "HoccerContentFactory.h"

@implementation HoccerAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize dataToSend;


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
	self.dataToSend =  UIImagePNGRepresentation([info objectForKey: UIImagePickerControllerOriginalImage]);
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
	
	NSString *type = @"image/png";
	NSString *filename = @"test.png";
	
	CLLocation *location = [self currentLocation];
	request = [[HoccerUploadRequest alloc] initWithLocation:location gesture:@"distribute" data: self.dataToSend 
													   type: type filename: filename delegate:self];
}


#pragma mark -
#pragma mark Download Communication Delegate Methods

- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest
{
	hoccerContent = [[HoccerContentFactory createContentFromResponse: aRequest.response 
														    withData: aRequest.result] retain];
	
	[viewController.view insertSubview: hoccerContent.view atIndex:0];
	// saveButton.title = [hoccerContent saveButtonDescription];
	
	// [viewController.toolbar setHidden: NO];
	// [viewController.view setNeedsDisplay];
	
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
	return locationManager.location;
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

- (IBAction)userDidCancelRequest
{
	NSLog(@"canceling..");
	[request cancel];
	[request release];
	
	request = nil;
}


- (IBAction)userDidSaveContent
{
	[hoccerContent save];
}

@end
