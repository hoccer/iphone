//
//  ReceivedContentView.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ReceivedContentView.h"
#import "NSObject+DelegateHelper.h"
#import "HoccerContent.h"

@implementation ReceivedContentView

@synthesize delegate;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[saveButton release];
	[toolbar release];
	[activity release];

	[super dealloc];
}

- (IBAction)onSave: (id)sender
{
	[self.delegate checkAndPerformSelector:@selector(userDidSaveContent)];
}

- (IBAction)onDismiss: (id)sender
{
	[self.delegate checkAndPerformSelector:@selector(userDidDismissContent)];
}

- (void)setHoccerContent: (id <HoccerContent>) content 
{	
	[self.view insertSubview: content.view atIndex:0];
	
	if ([content saveButtonDescription] == nil) {
		NSMutableArray *items = [NSMutableArray arrayWithArray: toolbar.items];
		[items removeObject: saveButton];
		
		[toolbar setItems:items animated: NO];
	} else {
		saveButton.title = [content saveButtonDescription];
	}
	
	[toolbar setHidden: NO];
	[self.view setNeedsDisplay];
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event
{
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}


-  (void)setWaiting
{
	activity.hidden = NO;
	[activity startAnimating];
	
	toolbar.hidden = YES;
}


@end
