    //
//  ReceiveViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ReceiveViewController.h"


@implementation ReceiveViewController

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
	NSLog(@"touches began in ReceiveViewController");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{	
	NSLog(@"touches moved in ReceiveViewController");
	
	//UITouch* touch = [touches anyObject];
//	CGPoint prevLocation = [touch previousLocationInView: self.view.superview];
//	CGPoint currentLocation = [touch locationInView: self.view.superview];
//	
//	CGRect myRect = self.view.frame;
//	myRect.origin.x += currentLocation.x - prevLocation.x; 
//	myRect.origin.y += currentLocation.y - prevLocation.y; 
	
	//self.view.frame = myRect;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{	
	
	//[self resetViewAnimated:YES];
	
	NSLog(@"touches ended in ReceiveViewController");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touches cancelled in ReceiveViewController");
}

@end
