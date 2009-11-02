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
#import  "NSString+StringWithData.h"

#import "HoccerViewController.h"
#import "HoccerDownloadRequest.h"
#import "HoccerUploadRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerContentFactory.h"
#import "GesturesInterpreter.h"
#import "HoccerAppDelegate.h"

#import "HoccerVcard.h"
#import "HoccerText.h"
#import "PreviewView.h"

#import "DragUpMenuViewController.h"


@implementation HoccerViewController

@synthesize delegate; 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	selectionViewController = [[DragUpMenuViewController alloc] initWithNibName:@"DragUpMenuViewController" bundle:nil];
	selectionViewController.delegate = self.delegate;
	
	CGSize size = mainScrollView.frame.size;
	size.height += selectionViewController.view.frame.size.height;
	
	CGRect buttonViewRect = selectionViewController.view.frame;
	buttonViewRect.origin.y = mainScrollView.frame.size.height;
	
	selectionViewController.view.frame = buttonViewRect;
	mainScrollView.contentSize = size;
	mainScrollView.delegate = self;
	[mainScrollView addSubview: selectionViewController.view];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[cancelButton release];
	[toolbar release];
    [statusLabel release];
	[locationLabel release];
	[infoView release];
	
	[activitySpinner release];
	[progressView release];
	[modeLabel release];
	[successView release];
	
	[mainScrollView release];
	
	[selectionViewController release];	
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


- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy
{
	if (placemark.thoroughfare != nil)
		locationLabel.text = [NSString stringWithFormat:@"%@ (~ %4.2fm)", placemark.thoroughfare, accuracy];
}	
	
- (void)setUpdate: (NSString *)update
{
	progressView.hidden = YES;

	activitySpinner.hidden = NO;
	statusLabel.hidden = NO;
	statusLabel.text = update;
}

- (void)setProgressUpdate: (CGFloat) percentage
{
	activitySpinner.hidden = YES;
	
	progressView.hidden = NO;
	progressView.progress = percentage;
}


- (void)showReceiveMode
{
	modeLabel.title = @"Receive";
	descriptionImage.hidden = NO;
}

- (void)showSendMode
{
	modeLabel.title = @"Share";
	descriptionImage.hidden = YES;
	
}

- (void)showSuccessMode
{
	successView.hidden = NO;
	[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideSuccessMode) userInfo:nil repeats:NO];
}

- (void)hideSuccessMode 
{
	successView.hidden = YES;
}


- (void)showConnectionActivity
{
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	
	animation.fromValue = [NSNumber valueWithCGPoint:CGPointMake(0, 0)];
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	infoView.hidden = NO;
	// [[infoView layer] addAnimation:animation forKey:<#(NSString *)key#>  
	
	[activitySpinner startAnimating];
}

- (void)hideConnectionActivity
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	infoView.hidden = YES;
	[activitySpinner stopAnimating];
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
	
	[currentPreview removeFromSuperview];
	
	PreviewView *contentView = [content previewWithFrame: CGRectMake(0, 0, 175, 175)];
	
	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
	originalFrame = CGRectMake(xOrigin, 60, contentView.frame.size.width, contentView.frame.size.height);
		
	contentView.delegate = self.delegate;
	
	[mainScrollView insertSubview: contentView atIndex: 1];
	[self.view setNeedsDisplay];
	
	currentPreview = contentView;
	[self resetPreview];
}

- (void)resetPreview
{
	
	currentPreview.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, 0, 0);
	
	// [UIView beginAnimations:@"showPreviewAnimation" context:NULL];
	// [UIView setAnimationDuration: 1];
	currentPreview.frame = originalFrame;
	// [UIView commitAnimations];
}

#pragma mark -
#pragma mark animations
 - (void)startPreviewFlyOutAniamation
{
	[UIView beginAnimations:@"myFlyOutAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	currentPreview.frame = CGRectMake(currentPreview.frame.origin.x, -200, 20, 20);
	[UIView commitAnimations];
}


- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	[currentPreview dismissKeyboard];
}

- (IBAction)showAbout: (id)sender 
{
	[self.delegate checkAndPerformSelector: @selector(userDidChoseAboutView)];
}

#pragma mark -
#pragma mark ScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (decelerate) {
		return;
	}
	
	[self scrollViewDidEndDecelerating: scrollView];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	float maxHeight = selectionViewController.view.frame.size.height;
	if (scrollView.contentOffset.y > maxHeight * 0.95) {
		[scrollView setContentOffset: CGPointMake(0, maxHeight) animated:YES];
	} else {
		[scrollView setContentOffset: CGPointMake(0, 0) animated:YES];
	}
}

@end
