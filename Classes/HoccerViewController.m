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
#import "Preview.h"

#import "DragUpMenuViewController.h"
#import "HiddenViewScrollViewDelegate.h"


@implementation HoccerViewController

@synthesize delegate; 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	selectionViewController = [[DragUpMenuViewController alloc] initWithNibName:@"DragUpMenuViewController" bundle:nil];
	selectionViewController.delegate = self.delegate;
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [statusLabel release];
	[locationLabel release];
	[infoView release];
	
	[activitySpinner release];
	[progressView release];
	
	[downIndicator release];
	
	[selectionViewController release];		
	[backgroundView release];
	
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


- (void)setLocation: (MKPlacemark *)placemark withAccuracy: (float) accuracy
{
	if (placemark.thoroughfare != nil)
		locationLabel.text = [NSString stringWithFormat:@"%@ (~ %4.2fm)", placemark.thoroughfare, accuracy];
}	
	
- (void)setUpdate: (NSString *)update
{
	progressView.progress = 0;
	
	progressView.hidden = NO;
	activitySpinner.hidden = NO;
	statusLabel.hidden = NO;
	statusLabel.text = update;
}

- (void)setProgressUpdate: (CGFloat) percentage
{
	progressView.hidden = NO;
	progressView.progress = percentage;
}


- (void)showReceiveMode
{
	[shareView removeFromSuperview];
	[backgroundView insertSubview:receiveView atIndex:0];
}

- (void)showSendMode
{
	[receiveView removeFromSuperview];
	[backgroundView insertSubview:shareView atIndex:0];
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
	
	Preview *contentView = [content preview];
	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
	contentView.origin = CGPointMake(xOrigin, 75);
	contentView.delegate = self.delegate;
	
	[shareView insertSubview: contentView atIndex: 1];
	[self.view setNeedsDisplay];
	
	currentPreview = contentView;
}

- (void)resetPreview
{
	[currentPreview resetViewAnimated:NO];
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



//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//	NSLog(@"touches began");
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{	
//	
//	UITouch* touch = [touches anyObject];
//	CGPoint prevLocation = [touch previousLocationInView: self.superview];
//	CGPoint currentLocation = [touch locationInView: self.superview];
//	
//	CGRect myRect = self.frame;
//	myRect.origin.x += currentLocation.x - prevLocation.x; 
//	myRect.origin.y += currentLocation.y - prevLocation.y; 
//	
//	self.frame = myRect;
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{	
//	
//	CGRect myRect = self.frame;
//	myRect.origin = origin;
//	self.frame = myRect;
//	
//	NSLog(@"touches ended");
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//	NSLog(@"touches cancelled");
//}



@end
