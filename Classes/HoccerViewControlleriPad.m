//
//  HoccerViewControlleriPad.m
//  Hoccer
//
//  Created by Robert Palmer on 23.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.

#import "HoccerViewControlleriPad.h"
#import "PreviewViewController.h"
#import "BackgroundViewController.h"
#import "Preview.h"
#import "NSObject+DelegateHelper.h"

#import "HoccerContent.h"
#import "HoccerImage.h"


@interface HoccerViewControlleriPad () 

@property (retain) UIPopoverController *popOver;

@end


@implementation HoccerViewControlleriPad
@synthesize popOver;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.previewViewController.shouldSnapBackOnTouchUp = NO;
	backgroundViewController.shouldSnapToCenterOnTouchUp = NO;
}


- (void) dealloc
{
	[popOver release];
	
	[super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)selectImage: (id)sender {
	if (self.popOver != nil) {
		[self.popOver dismissPopoverAnimated:YES];
		self.popOver = nil;
		return;
	}
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	
	self.popOver = [[[UIPopoverController alloc] initWithContentViewController:imagePicker] autorelease];
	self.popOver.delegate = self; 
	[self.popOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 

	[imagePicker release];
}

- (IBAction)selectContacts: (id)sender {
	if (self.popOver != nil) {
		[self.popOver dismissPopoverAnimated:YES];
		self.popOver = nil;
		return;
	}
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	picker.contentSizeForViewInPopover = CGSizeMake(300.0, 280.0);
	
	self.popOver = [[[UIPopoverController alloc] initWithContentViewController:picker] autorelease];
	self.popOver.delegate = self; 
	[self.popOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 

	[picker release];
}

- (void)setContentPreview: (id <HoccerContent>)content {
	[self.previewViewController.view removeFromSuperview];
	Preview *contentView = [content preview];
	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
	
	[backgroundView insertSubview: contentView atIndex: 1];
	[self.view setNeedsDisplay];
	
	self.previewViewController.view = contentView;	
	self.previewViewController.origin = CGPointMake(xOrigin, backgroundView.frame.size.height * 0.3);
}



#pragma mark -
#pragma mark UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	id <HoccerContent> content = [[[HoccerImage alloc] initWithUIImage:
								   [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease];
	
	[self.delegate checkAndPerformSelector:@selector(hoccerViewController:didSelectContent:) withObject:self withObject: content];
	
	[self setContentPreview: content];
}

#pragma mark -
#pragma mark UIPopoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	
	self.popOver = nil;
}



@end
