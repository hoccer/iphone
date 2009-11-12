//
//  ContentSelectionButtonView.m
//  Hoccer
//
//  Created by Robert Palmer on 02.11.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "DragUpMenuViewController.h"
#import "NSObject+DelegateHelper.h"


@implementation DragUpMenuViewController

@synthesize delegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)selectContacts: (id)sender
{
	[self.delegate checkAndPerformSelector:@selector(userWantsToSelectContact)];
}

- (IBAction)selectImage: (id)sender 
{
	[self.delegate checkAndPerformSelector:@selector(userWantsToSelectImage)];

}

- (IBAction)selectText: (id)sender
{
	[self.delegate checkAndPerformSelector:@selector(userDidPickText)];

}



- (void)dealloc {
    [super dealloc];
}


@end
