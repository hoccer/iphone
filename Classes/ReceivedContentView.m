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
