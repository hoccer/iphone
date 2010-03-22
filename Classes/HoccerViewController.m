//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
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

#import "HelpScrollView.h"

@interface HoccerViewController ()

- (void)showPopOver: (UIViewController *)popOverView;
- (void)hidePopOverAnimated: (BOOL) animate;
- (void)removePopOverFromSuperview;

- (void)showSelectContentView;
- (void)showHelpView;

@end


@implementation HoccerViewController

@synthesize delegate; 
@synthesize popOver;
@synthesize allowSweepGesture;

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
	
	self.allowSweepGesture = YES;
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[sweepInView release];

	[previewViewController release];		
	[backgroundViewController release];		
	
	[shareView release];
	[receiveView release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark User Interaction
- (IBAction)onCancel: (id)sender {
	[self.delegate checkAndPerformSelector:@selector(userDidCancelRequest)];
}

- (IBAction)didDissmissContentToThrow: (id)sender {
	[self.delegate checkAndPerformSelector: @selector(didDissmissContentToThrow)];
}

- (IBAction)didSelectHelp: (id)sender {
	[self.delegate checkAndPerformSelector: @selector(userDidChoseHelpView)];
}

- (void)showReceiveMode {
	[shareView removeFromSuperview];
	[self.view insertSubview:receiveView atIndex:0];
}

- (void)showSendMode {
	[receiveView removeFromSuperview];
	[self.view insertSubview:shareView atIndex:0];
}


- (void)showError: (NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil 
											  cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	
	[alertView show];
	[alertView release];
}


- (void)setContentPreview: (id <HoccerContent>)content {
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

- (void)resetPreview {
	[previewViewController resetViewAnimated:NO];
	[backgroundViewController resetView];
}

- (IBAction)selectContacts: (id)sender {
	[self hidePopOverAnimated: YES];
	[self.delegate checkAndPerformSelector:@selector(userWantsToSelectContact)];
	
}

- (IBAction)selectImage: (id)sender {
	[self hidePopOverAnimated: NO];
	[self.delegate checkAndPerformSelector:@selector(userWantsToSelectImage)];
}

- (IBAction)selectText: (id)sender {
	[self hidePopOverAnimated: YES];
	[self.delegate checkAndPerformSelector:@selector(userDidPickText)];	
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	[previewViewController dismissKeyboard];
}

- (IBAction)showAbout: (id)sender {
	[self.delegate checkAndPerformSelector: @selector(userDidChoseAboutView)];
}


- (void)startPreviewFlyOutAniamation {
	[previewViewController startFlyOutUpwardsAnimation];
}

- (IBAction)toggleSelectContacts: (id)sender{
	if (!isPopUpDisplayed) {			
		[self showSelectContentView];
	} else {
		[self hidePopOverAnimated: YES];
	}
}

- (void)showSelectContentView {
	SelectContentViewController *selectContentViewController = [[SelectContentViewController alloc] init];
	selectContentViewController.delegate = self;
	
	[self showPopOver: selectContentViewController];
	[selectContentViewController release];
}


- (IBAction)toggleHelp: (id)sender {
	if (!isPopUpDisplayed) {			
		[self showHelpView];
	} else {
		[self hidePopOverAnimated: YES];
	}
}


- (void)showHelpView {
	HelpScrollView *helpView = [[HelpScrollView alloc] init];
	helpView.delegate = self;
	
	[self showPopOver:helpView];
	[helpView release];
}


- (void)showPopOver: (UIViewController *)popOverView  {
	self.popOver = popOverView;
	
	CGRect selectContentFrame = popOverView.view.frame;
	selectContentFrame.size = backgroundViewController.view.frame.size;
	selectContentFrame.origin= CGPointMake(0, self.view.frame.size.height);
	popOverView.view.frame = selectContentFrame;	
	
	[backgroundViewController.view addSubview:popOverView.view];
	
	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	
	selectContentFrame.origin = CGPointMake(0,0);
	popOverView.view.frame = selectContentFrame;
	[UIView commitAnimations];
	
	 isPopUpDisplayed = TRUE;
}

- (void)hidePopOverAnimated: (BOOL) animate {
	if (self.popOver != nil) {		
		CGRect selectContentFrame = self.popOver.view.frame;
		selectContentFrame.origin = CGPointMake(0, self.view.frame.size.height);
		
		if (animate) {
			[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
			[UIView setAnimationDidStopSelector:@selector(removePopOverFromSuperview)];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.2];
			
			self.popOver.view.frame = selectContentFrame;
			
			[UIView commitAnimations];
		} else {
			self.popOver.view.frame = selectContentFrame;
			[self removePopOverFromSuperview];
		}

	}
}

- (void)removePopOverFromSuperview {	
	[popOver.view removeFromSuperview];	 
	self.popOver = nil;

	isPopUpDisplayed = NO;
}

- (void)setAllowSweepGesture: (BOOL)allow {
	backgroundViewController.blocked = !allow;
}

@end
