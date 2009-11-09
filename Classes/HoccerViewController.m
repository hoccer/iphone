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
#import "HiddenViewScrollViewDelegate.h"


@implementation HoccerViewController

@synthesize delegate; 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
// 	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Background" ofType:@"png"];
//	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile: backgroundImagePath]];
	[backgroundView setNeedsDisplay];
	
	selectionViewController = [[DragUpMenuViewController alloc] initWithNibName:@"DragUpMenuViewController" bundle:nil];
	selectionViewController.delegate = self.delegate;
	
	hiddenViewDelegate = [[HiddenViewScrollViewDelegate alloc] init];
	hiddenViewDelegate.scrollView = mainScrollView;
	hiddenViewDelegate.indicatorView = downIndicator;
	hiddenViewDelegate.hiddenView = selectionViewController.view;

	CGRect bottomViewRect = selectionViewController.view.frame;
	bottomViewRect.origin.y = mainScrollView.frame.size.height;
	selectionViewController.view.frame = bottomViewRect;

	mainScrollView.contentSize = mainScrollView.frame.size;;
	mainScrollView.delegate = hiddenViewDelegate;
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
	[downIndicator release];
	
	[selectionViewController release];	
	[hiddenViewDelegate release];
	
	[backgroundView release];
	
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
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	infoView.hidden = NO;
	infoView.center = CGPointMake(160, -35);
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.fromValue = [NSNumber valueWithCGPoint:CGPointMake(160, -35)];
	animation.toValue = [NSNumber valueWithCGPoint: CGPointMake(160, 30)];
	animation.duration = 0.2;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.beginTime = CACurrentMediaTime() + 0.6;
	animation.delegate = self;

	[[infoView layer] addAnimation:animation forKey:@"positionAnimation"];  

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
	[mainScrollView setContentOffset: CGPointMake(0, 0) animated: NO];
	
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
#pragma mark CAAnimation Delegate Methods
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag 
{
	infoView.center = CGPointMake(160, 30);
}

@end
