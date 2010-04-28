//
//  SelectContentController.m
//  Hoccer
//
//  Created by Robert Palmer on 28.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "SelectContentController.h"


@implementation SelectContentController
@synthesize delegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor clearColor];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction)camera: (id)sender; {
	
}

- (IBAction)image: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectImage:) withObject: self];
}

- (IBAction)video: (id)sender; {
	
}

- (IBAction)text: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectText:) withObject: self];

}

- (IBAction)contact: (id)sender; {
	[delegate checkAndPerformSelector:@selector(selectContacts:) withObject: self];
}

- (IBAction)mycontact: (id)sender; {
	
}


@end
