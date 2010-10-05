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
- (void)setReady;
- (void)setWaiting;
@end



@implementation ReceivedContentViewController

@synthesize delegate;
@synthesize hoccerContent;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
}


- (void)dealloc {
	[hoccerContent release];
	[saveButton release];
	[toolbar release];
	[HUD release];
	
	[super dealloc];
}

- (IBAction)save: (id)sender	{
	[hoccerContent whenReadyCallTarget:self selector:@selector(setReady) context: nil];
	if ([hoccerContent needsWaiting]) {
		[self setWaiting];
	}
	
	if ([hoccerContent saveDataToContentStorage]) {
		return;
	}
	
	if (![hoccerContent.interactionController presentOpenInMenuFromRect:CGRectNull inView:self.view.superview animated:YES]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot handle content", nil) 
															message:NSLocalizedString(@"No installed program can handle this content type.", nil) 
														   delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
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
	[self setReady];
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextView class]]) {
			[view resignFirstResponder];
		}
	}
}


-  (void)setWaiting {
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Saving";
	
	[HUD show:YES];
	toolbar.hidden = YES;
}

- (void)setReady {
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	HUD.labelText = @"Saved";
	[NSTimer scheduledTimerWithTimeInterval:1 target: self selector:@selector(hideHUD) userInfo:nil repeats:NO];
	
	toolbar.hidden = NO;
}

- (void)hideHUD {
	[HUD hide:YES];
}


@end
