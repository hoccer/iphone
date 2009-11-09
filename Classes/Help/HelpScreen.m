//
//  HelpScreen.m
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "HelpScreen.h"

#import "HelpContent.h"
#import "FeedbackProvider.h"

@implementation HelpScreen

@synthesize content;

- (id)initWithHelpContent: (HelpContent *)helpContent;
{
	self = [super initWithNibName:@"HelpScreen" bundle:nil];
	if (self != nil) {
		self.content = helpContent;

	}
	
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	header.text = self.content.name;
	description.text = self.content.description;
	imageView.image = [UIImage imageWithContentsOfFile: self.content.imagePath];
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


- (IBAction)playVideo: (id)sender
{

	MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:
								[NSURL fileURLWithPath:self.content.videoPath]];
	
	[player play];
}

- (void)dealloc {
    [description release];
	[header release];
	[imageView release];
	
	self.content = nil;
	
	[super dealloc];
}





@end