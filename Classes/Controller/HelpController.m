//
//  HelpController.m
//  Hoccer
//
//  Created by Robert Palmer on 04.02.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HelpController.h"
#import "HelpScrollView.h"


@implementation HelpController

- (id)initWithController: (UINavigationController *)viewController {
	self = [super init];
	if (self != nil) {
		controller = [viewController retain];
	}
	
	return self;
}
	
- (void)viewDidLoad {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome to Hoccer", nil)
													message:NSLocalizedString(@"Do you want to see the tutorial to learn how hoccer works?", nil)
												   delegate:self 
										  cancelButtonTitle:@"Continue" otherButtonTitles:@"Show Tutorial", nil];
	[alert show];	
	[alert release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"selected: %d", buttonIndex);
	if (buttonIndex == 1) {
		HelpScrollView *helpView = [[HelpScrollView alloc] initWithNibName:@"HelpScrollView" bundle:nil];
		helpView.navigationItem.title = @"Tutorial";
		[controller pushViewController:helpView animated:YES];
		[helpView release];
	}
}

- (void) dealloc {
	[controller release];
	[super dealloc];
}




@end
