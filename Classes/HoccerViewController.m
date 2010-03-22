//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>

#import "ABPersonVCardCreator.h"
#import "NSObject+DelegateHelper.h"
#import "NSString+StringWithData.h"

#import "HoccerViewController.h"
#import "HoccerAppDelegate.h"

#import "HoccerVcard.h"
#import "HoccerText.h"
#import "Preview.h"

#import "HiddenViewScrollViewDelegate.h"
#import "PreviewViewController.h"
#import "BackgroundViewController.h"
#import "SelectContentViewController.h"
#import "StatusViewController.h"

@implementation HoccerViewController

@synthesize delegate; 
@synthesize statusViewController;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	previewViewController = [[PreviewViewController alloc] init];
	backgroundViewController = [[BackgroundViewController alloc] init];
	backgroundViewController.view = receiveView;

	backgroundViewController.feedback = sweepInView;
	backgroundViewController.delegate = self.delegate;
	sweepInView.hidden = YES;
    isPopUpDisplayed = FALSE;
	[receiveView addSubview: sweepInView];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[sweepInView release];

	[previewViewController release];		
	[backgroundViewController release];		
	[statusViewController release];		
	
	[shareView release];
	[receiveView release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark User Interaction
- (IBAction)onCancel: (id)sender 
{
	[self.delegate checkAndPerformSelector:@selector(userDidCancelRequest)];
}

- (IBAction)didDissmissContentToThrow: (id)sender
{
	[self.delegate checkAndPerformSelector: @selector(didDissmissContentToThrow)];
}

-  (IBAction)didSelectHelp: (id)sender
{
	[self.delegate checkAndPerformSelector: @selector(userDidChoseHelpView)];
}
	
- (void)setUpdate: (NSString *)update
{
	[statusViewController setUpdate: update];
}

- (void)setProgressUpdate: (CGFloat) percentage
{
	[statusViewController setProgressUpdate: percentage];
}


- (void)showReceiveMode
{
	[shareView removeFromSuperview];
	[self.view insertSubview:receiveView atIndex:0];
}

- (void)showSendMode
{
	//[receiveViewController.view removeFromSuperview];
	[receiveView removeFromSuperview];
	[self.view insertSubview:shareView atIndex:0];
}


- (void)showError: (NSString *)message
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil 
											  cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	
	[alertView show];
	[alertView release];
}


- (void)setContentPreview: (id <HoccerContent>)content
{
	if (content == nil) {
		[self showReceiveMode];
	} else {
		[self showSendMode];
	}
	
	[previewViewController.view removeFromSuperview];
	
	Preview *contentView = [content preview];
	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
	
	[shareView insertSubview: contentView atIndex: 1];
	[self.view setNeedsDisplay];
	
	previewViewController.view = contentView;	
	previewViewController.origin = CGPointMake(xOrigin, 75);
	previewViewController.delegate = self.delegate;
}

- (void)resetPreview
{
	[previewViewController resetViewAnimated:NO];
	[backgroundViewController resetView];
}

- (IBAction)selectContacts: (id)sender
{
	[self hideSelectContentViewAnimated: YES];
	[self.delegate checkAndPerformSelector:@selector(userWantsToSelectContact)];
	
}

- (IBAction)selectImage: (id)sender 
{
	[self hideSelectContentViewAnimated: NO];
	[self.delegate checkAndPerformSelector:@selector(userWantsToSelectImage)];
}

- (IBAction)selectText: (id)sender
{
	[self hideSelectContentViewAnimated: YES];
	[self.delegate checkAndPerformSelector:@selector(userDidPickText)];	
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	[previewViewController dismissKeyboard];
}

- (IBAction)showAbout: (id)sender 
{
	[self.delegate checkAndPerformSelector: @selector(userDidChoseAboutView)];
}

#pragma mark -
#pragma mark CAAnimation Delegate Methods
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag 
{
	// infoView.center = CGPointMake(160, 30);
}

- (void)startPreviewFlyOutAniamation {
	[previewViewController startFlyOutUpwardsAnimation];
}

- (IBAction)toggleSelectContacts: (id)sender{
	if (!isPopUpDisplayed) {			
		[self showSelectContentView];
	} else {
		[self hideSelectContentViewAnimated: TRUE];
	}
}

- (void)showSelectContentView{
	selectContentViewController = [[SelectContentViewController alloc] init];
	selectContentViewController.delegate = self;
	CGRect selectContentFrame = selectContentViewController.view.frame;
	selectContentFrame.size = backgroundViewController.view.frame.size;
	selectContentFrame.origin= CGPointMake(0, self.view.frame.size.height);
	selectContentViewController.view.frame = selectContentFrame;	
	[backgroundViewController.view addSubview:selectContentViewController.view];
	
	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	selectContentFrame.origin = CGPointMake(0,0);
	selectContentViewController.view.frame = selectContentFrame;
	[UIView commitAnimations];
	isPopUpDisplayed = TRUE;
}

- (void)hideSelectContentViewAnimated: (BOOL) animate{
	if(selectContentViewController != nil){	
		
		CGRect selectContentFrame = selectContentViewController.view.frame;
		selectContentFrame.origin = CGPointMake(0, self.view.frame.size.height);
		
		if (animate) {
			[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
			[UIView setAnimationDidStopSelector:@selector(removeSelectContentViewFromSuperview)];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.2];
			selectContentViewController.view.frame = selectContentFrame;
			[UIView commitAnimations];
		} else {
			selectContentViewController.view.frame = selectContentFrame;
			[self removeSelectContentViewFromSuperview];
		}

	}
}

- (void)removeSelectContentViewFromSuperview{	
	[selectContentViewController.view removeFromSuperview];	 
	[selectContentViewController release];
	selectContentViewController = nil;
	isPopUpDisplayed = FALSE;
}




@end
