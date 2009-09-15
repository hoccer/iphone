//
//  DebugViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "DebugViewController.h"
#import "AccelerationRecorder.h"

@interface DebugViewController (Private) 
- (void)turnRecordingOn;
- (void)turnRecordingOff;

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
	NSLog(@"starting recording: %@", recorder);
	[recorder startRecording];
	[recordingButton setTitle: @"Record Acceleration" forState: UIControlStateNormal ];
	self.recording = YES;
}

- (void)turnRecordingOff
{
	NSLog(@"stoping recording");
	[recorder stopRecording];
	[recordingButton setTitle: @"Stop Recording" forState: UIControlStateNormal ];

	self.recording = NO;
}


@end
