//
//  MyViewController.m
//  UITest
//
//  Created by david on 14.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyViewController.h"


@implementation MyViewController

@synthesize textField;
@synthesize greetingLabel;
@synthesize locationLabel;
@synthesize accuracyLabel;

@synthesize string;

- (IBAction)changeGreeting:(id)sender {
	self.string = textField.text;
	
    NSString *nameString = string;
    if ([nameString length] == 0) {
        nameString = @"World";
    }
    NSString *greetingText = [[NSString alloc] initWithFormat:@"Hello, %@!", nameString];
    greetingLabel.text = greetingText;
    [greetingText release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	NSLog(@"textFieldShouldReturn");
    if (theTextField == textField) {
        [textField resignFirstResponder];
    }
    return YES;
}


- (void)locationUpdate:(CLLocation *)location {
	NSString * tmpString = [[NSString alloc] initWithFormat:@"Lon: %f Lat: %f", location.coordinate.longitude,
							   location.coordinate.latitude];
    locationLabel.text = tmpString;

	[tmpString release];

    tmpString = [[NSString alloc] initWithFormat: @"Accuracy: %f", location.horizontalAccuracy];
    accuracyLabel.text = tmpString;
}

- (void)locationError:(NSError *)error {
    debugLog.text = [error description];
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
	[textField release];
    [greetingLabel release];
    [string release];
	
	[locationController release];
	
    [super dealloc];
}


@end
