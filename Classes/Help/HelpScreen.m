//
//  HelpScreen.m
//  Hoccer
//
//  Created by Robert Palmer on 27.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "HelpScreen.h"

#import "HelpContent.h"
#import "FeedbackProvider.h"

@implementation HelpScreen
@synthesize player;

@synthesize content;

- (id)initWithHelpContent: (HelpContent *)helpContent;
{
	self = [super initWithNibName:@"HelpScreen" bundle:nil];
	if (self != nil) {
		self.content = helpContent;
        CGRect screenRect;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            screenRect = [[UIScreen mainScreen] bounds];
            screenRect.size.height = screenRect.size.height - (20+44+48);
        }
        else {
            screenRect = CGRectMake(0, 0, 320, 467);
        }
        self.view.frame = screenRect;
	}
	
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	header.text = self.content.name;
	description.text = self.content.description;
	imageView.image = [UIImage imageWithContentsOfFile: self.content.imagePath];
    
    description.userInteractionEnabled = NO;
    [description sizeToFit];
    
    videoButton.hidden = self.content.videoPath == nil;
    if (!videoButton.hidden) {
        [videoButton setTitle:NSLocalizedString(@"Button_PlayVideo", nil) forState:UIControlStateNormal];
    }
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


- (IBAction)playVideo:(id)sender {
    /*
	UIView *window = [[UIApplication sharedApplication] keyWindow];
	
	self.player = [[[MPMoviePlayerController alloc] initWithContentURL: [NSURL fileURLWithPath:self.content.videoPath]] autorelease];
	[window addSubview: [player view]];
	[player play];
	[player setFullscreen:YES animated:YES];
     */
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.content.videoPath]];
    player.view.frame = CGRectMake(78, 10, 160, 160);
    player.view.backgroundColor = [UIColor clearColor];
    player.controlStyle = MPMovieControlStyleNone;
    [player prepareToPlay];
    imageView.hidden =TRUE;
    [self.view addSubview:player.view];
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(moviePlayBackDidFinish:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:nil];
    [player play];
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    player.view.hidden = TRUE;
    imageView.hidden = FALSE;
}

- (void)dealloc {
    [description release];
	[header release];
	[imageView release];
	[player release];
	[videoButton release];
	
	self.content = nil;
	
	[super dealloc];
}





@end
