//
//  MyViewController.m
//  UITest
//
//  Created by david on 14.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyViewController.h"



@implementation MyViewController

@synthesize locationLabel;
@synthesize accuracyLabel;

- (void)locationUpdate:(CLLocation *)location {
	NSString * tmpString = [[NSString alloc] initWithFormat:@"Lon: %f Lat: %f", location.coordinate.longitude,
							   location.coordinate.latitude];
    locationLabel.text = tmpString;

	[tmpString release];

    tmpString = [[NSString alloc] initWithFormat: @"Accuracy: %f", location.horizontalAccuracy];
    accuracyLabel.text = tmpString;
	
	[tmpString release];
}

- (void)locationError:(NSError *)error {
    debugLog.text = [error description];
}

- (IBAction) testHTTPRequest:(id) sender {
    NSLog(@"HTTP Request Test");
	[downloadController fetchURL: [NSURL URLWithString: @"http://localhost/cgi-bin/dump_request.pl"]];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
    [locationController.locationManager startUpdatingLocation];
	
	downloadController = [[MyDownloadController alloc] init];
	downloadController.delegate = self;
	
    [super viewDidLoad];
}


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
    [locationLabel release];	
    [accuracyLabel release];	
	[locationController release];
	[downloadController release];
	
    [super dealloc];
}

- (void) onDownloadDone: (NSMutableData*) theData {
	NSLog(@"Got data");
	
	NSString * tmp  = [[NSString alloc] initWithData:theData encoding: NSUTF8StringEncoding];
	debugLog.text = tmp;
	[tmp release];
	
}

- (void) onError: (NSError*) theError {
	// inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [theError localizedDescription],
          [[theError userInfo] objectForKey:NSErrorFailingURLStringKey]);
}


@end
