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
#import "HoccerImage.h"

@interface ReceivedContentViewController () 
- (void)hideReceivedContentView;

@end



@implementation ReceivedContentViewController

@synthesize delegate;
@synthesize hoccerContent;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}


- (void)dealloc {
	[hoccerContent release];
	[saveButton release];
	[toolbar release];
	[activity release];

	[super dealloc];
}

- (IBAction)save: (id)sender	{
	if ([hoccerContent needsWaiting] && [hoccerContent isKindOfClass: [HoccerImage class]]){
		[self setWaiting];
		[(HoccerImage*) hoccerContent whenReadyCallTarget:self selector:@selector(hideReceivedContentView)];
		[hoccerContent saveDataToContentStorage];
	} else {
		[self hideReceivedContentView];
		[hoccerContent saveDataToContentStorage];
	}
}

- (IBAction)resend: (id)sender {
	hoccerContent.persist = YES;
	[delegate checkAndPerformSelector:@selector(receiveContentController:wantsToResendContent:) withObject:self withObject:hoccerContent];
}

- (void)setHoccerContent: (HoccerContent*) content {	
	if (hoccerContent != content) {
		[hoccerContent release];
		hoccerContent = [content retain];
	}
	
	[self.view insertSubview: content.fullscreenView atIndex:0];
	
	if ([content descriptionOfSaveButton] == nil) {
		NSMutableArray *items = [NSMutableArray arrayWithArray: toolbar.items];
		[items removeObject: saveButton];
		
		[toolbar setItems:items animated: NO];
	} else {
		saveButton.title = [content descriptionOfSaveButton];
	}
	
	[toolbar setHidden: NO];
	[self.view setNeedsDisplay];
}

#pragma mark -
#pragma mark ReceivedContentView Delegate Methods

-  (void)hideReceivedContentView {
	[self setWaiting];
	[self.delegate checkAndPerformSelector:@selector(receivedViewContentControllerDidFinish:) withObject: self];
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	for (UIView* view in self.view.subviews) {
		
		if ([view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}


-  (void)setWaiting {
	activity.hidden = NO;
	[activity startAnimating];
	
	toolbar.hidden = YES;
}


@end
