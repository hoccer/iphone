//
//  ReceivedContentView.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ReceivedContentViewController.h"
#import "NSObject+DelegateHelper.h"
#import "HoccerContent.h"

@interface ReceivedContentViewController () 
- (void)hideReceivedContentView;

@end



@implementation ReceivedContentViewController

@synthesize delegate;
@synthesize hoccerContent;

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
	[hoccerContent release];
	[saveButton release];
	[toolbar release];
	[activity release];

	[super dealloc];
}

- (IBAction)onSave: (id)sender
{
	if ([hoccerContent needsWaiting])  {
		
		[self setWaiting];
		[hoccerContent whenReadyCallTarget:self selector:@selector(hideReceivedContentView)];
		[hoccerContent save];
	} else {
		[self hideReceivedContentView];
		[hoccerContent save];
	}
}

- (IBAction)onDismiss: (id)sender
{
	[self hideReceivedContentView];
}

- (void)setHoccerContent: (id <HoccerContent>) content 
{	
	if (hoccerContent != content) {
		[hoccerContent release];
		hoccerContent = [content retain];
	}
	
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

#pragma mark -
#pragma mark ReceivedContentView Delegate Methods

-  (void)hideReceivedContentView 
{
	[self.delegate checkAndPerformSelector:@selector(receivedViewContentControllerDidFinish:) withObject: self];
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
