//
//  HoccerViewControlleriPad.m
//  Hoccer
//
//  Created by Robert Palmer on 23.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.

#import "HoccerViewControlleriPad.h"
#import "PreviewViewController.h"
#import "Preview.h"

@implementation HoccerViewControlleriPad

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)selectImage: (id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	
	UIPopoverController *imagePopOver = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
	[imagePopOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 

	[imagePicker release];
}

- (IBAction)selectContacts: (id)sender {
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	UIPopoverController *contactsPopOver = [[UIPopoverController alloc] initWithContentViewController:picker];
	[contactsPopOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 

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



@end
