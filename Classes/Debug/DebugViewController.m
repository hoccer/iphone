//
//  DebugViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "DebugViewController.h"
#import "AccelerationRecorder.h"
#import "FeatureHistory.h"

@interface DebugViewController (Private) 
- (void)turnRecordingOn;
- (void)turnRecordingOff;

- (void)showImage;

@end



@implementation DebugViewController

@synthesize recording;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	recorder = [[AccelerationRecorder alloc] init];
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
    [super dealloc];
	
	[recorder release];
	[recordingButton release];
	[imageView release];
}


- (IBAction) record: (id)sender
{
	if (self.recording) {
		[self turnRecordingOff];
	} else {
		[self turnRecordingOn];
	}
}


- (void)turnRecordingOn
{
	[recorder startRecording];
	[recordingButton setTitle: @"Stop Recording" forState: UIControlStateNormal ];
	self.recording = YES;
}

- (void)turnRecordingOff
{
	[recorder stopRecording];
	[recordingButton setTitle: @"Record Acceleration" forState: UIControlStateNormal ];

	self.recording = NO;
	
	[self showImage];
}

- (void)showImage
{
	UIImage *chart = [recorder.featureHistory chart];
	
	imageView.frame = CGRectMake(0, 0, chart.size.width, chart.size.height);
	((UIScrollView *)imageView.superview).contentSize = CGSizeMake(chart.size.width, chart.size.height);
	imageView.image = chart;
	
	[imageView.superview setNeedsLayout]; 
}


@end
