    //
//  PreviewViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "PreviewViewController.h"
#import "Preview.h"
#import "NSObject+DelegateHelper.h"

@implementation PreviewViewController

@synthesize origin;
@synthesize delegate;

- (id) init{
	
	self = [super init];
	if (self){
		self.view = nil;
	}
	return self;	
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[Preview alloc] initWithFrame: previewView];
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) setView:(UIView *) aPreview{
	super.view = aPreview;
	
	if ([self.view isKindOfClass: [Preview class]]) {
		[(Preview*) self.view setCloseActionTarget:self action:@selector(userDismissedContent:)];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	
    [super dealloc];
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touches began");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{	
	NSLog(@"touches moved");

	UITouch* touch = [touches anyObject];
	CGPoint prevLocation = [touch previousLocationInView: self.view.superview];
	CGPoint currentLocation = [touch locationInView: self.view.superview];
	
	CGRect myRect = self.view.frame;
	myRect.origin.x += currentLocation.x - prevLocation.x; 
	myRect.origin.y += currentLocation.y - prevLocation.y; 
	
	self.view.frame = myRect;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{	
	
	[self resetViewAnimated:YES];
	
	NSLog(@"touches ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touches cancelled");
}

- (void)dismissKeyboard
{
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}

- (void)resetViewAnimated: (BOOL)animated {
	NSLog(@"in %s", _cmd);
	CGRect myRect = self.view.frame;
	myRect.origin = origin;
	
	
	self.view.frame = myRect;
	self.view.userInteractionEnabled = YES;
	
//	[self.view setNeedsLayout];
}

- (void)setOrigin: (CGPoint)newOrigin {
	origin = newOrigin;
	[self resetViewAnimated: NO];
}

- (void)userDismissedContent: (id)sender
{
	[self.delegate checkAndPerformSelector: @selector(didDissmissContentToThrow)];
}

#pragma mark -
#pragma mark animations
- (void)startPreviewFlyOutAnimation
{
	[UIView beginAnimations:@"myFlyOutAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	CGRect myRect = self.view.frame;
	myRect.origin = CGPointMake(origin.x, -200);
	
	self.view.frame = myRect;
	[UIView commitAnimations];
}

@end
