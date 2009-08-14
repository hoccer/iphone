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
@synthesize label;
@synthesize string;

- (IBAction)changeGreeting:(id)sender {
	self.string = textField.text;
	
    NSString *nameString = string;
    if ([nameString length] == 0) {
        nameString = @"World";
    }
    NSString *greeting = [[NSString alloc] initWithFormat:@"Hello, %@!", nameString];
    label.text = greeting;
    [greeting release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	NSLog(@"textFieldShouldReturn");
    if (theTextField == textField) {
        [textField resignFirstResponder];
    }
    return YES;
}


- (void)locationUpdate:(CLLocation *)location {
    locationLabel.text = [location description];
}

- (void)locationError:(NSError *)error {
    locationLabel.text = [error description];
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
    [label release];
    [string release];
	
	[locationController release];
	
    [super dealloc];
}


@end
