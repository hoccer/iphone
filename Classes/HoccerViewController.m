//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "NSObject+DelegateHelper.h"

#import "HoccerViewController.h"
#import "HoccerDownloadRequest.h"
#import "HoccerUploadRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerContentFactory.h"
#import "GesturesInterpreter.h"

@implementation HoccerViewController

@synthesize delegate; 

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad {
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[saveButton release];
	[toolbar release];
    [statusLabel release];
	[locationLabel release];
	
	[super dealloc];
}


- (IBAction)onCancel: (id)sender 
{
	NSLog(@"canceling: %@", self.delegate);
	[self.delegate checkAndPerformSelector:@selector(userDidCancelRequest)];
}

- (IBAction)save: (id)sender 
{
	[self.delegate checkAndPerformSelector:@selector(userDidSaveRequest)];
}

- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy
{
	if (placemark.thoroughfare != nil)
		locationLabel.text = [NSString stringWithFormat:@"%@ (~ %4.2fm)", placemark.thoroughfare, accuracy];

}	
	
- (void)setUpdate: (NSString *)update
{
	statusLabel.text = update;
}	

@end
