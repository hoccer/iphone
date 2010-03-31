//
//  HoccerViewControlleriPad.m
//  Hoccer
//
//  Created by Robert Palmer on 23.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.

#import "HoccerViewControlleriPad.h"
#import "DesktopView.h"
#import "ReceivedContentViewController.h"
#import "Preview.h"
#import "NSObject+DelegateHelper.h"

#import "HoccerContent.h"
#import "HoccerImage.h"

#import "DesktopDataSource.h"
#import "HocItemData.h";


@interface HoccerViewControlleriPad () 

@property (retain) UIPopoverController *popOver;
- (UIPopoverController *)popOverWithController: (UIViewController*)controller;
@end


@implementation HoccerViewControlleriPad
@synthesize popOver;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	desktopView.shouldSnapToCenterOnTouchUp = NO;
	desktopView.dataSource = desktopData;
}


- (void) dealloc {
	[popOver release];
	[desktopData release];
	
	[super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)selectImage: (id)sender {
	if ([self.popOver.contentViewController isKindOfClass:[UIImagePickerController class]]) {
		[self.popOver dismissPopoverAnimated:YES];
		self.popOver = nil;

		return;
	}
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;

	self.popOver = [self popOverWithController: imagePicker];
	[self.popOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 

	[imagePicker release];
}

- (IBAction)selectContacts: (id)sender {
	if ([self.popOver.contentViewController isKindOfClass:[ABPeoplePickerNavigationController class]]) {
		[self.popOver dismissPopoverAnimated:YES];
		self.popOver = nil;

		return;
	}
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	self.popOver = [self popOverWithController: picker];
	[self.popOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 

	[picker release];
}

- (IBAction)selectText: (id)sender {
	if (self.popOver.popoverVisible == YES) {
		[self.popOver dismissPopoverAnimated:YES];
		self.popOver = nil;
	}
	
	[super selectText: sender];
}

- (void)setContentPreview: (HoccerContent*)content {
	
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.viewOrigin = CGPointMake(300, 300);
	item.content = content;
	item.delegate = self;
	
	[desktopData addHocItem:item];
	[desktopView reloadData];
	[desktopView reloadData];
}

- (void)presentReceivedContent:(HoccerContent*) content {}

- (UIViewController* )documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
}

#pragma mark -
#pragma mark UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	HoccerContent* content = [[[HoccerImage alloc] initWithUIImage:
								   [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease];
	
	[self.delegate checkAndPerformSelector:@selector(hoccerViewController:didSelectContent:) withObject:self withObject: content];
	[self setContentPreview:content];
}

#pragma mark -
#pragma mark UIPopoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.popOver = nil;
}


#pragma mark -
#pragma mark private Methods

- (UIPopoverController *)popOverWithController: (UIViewController*)controller {
	if (popOver == nil) {
		
		popOver = [[UIPopoverController alloc] initWithContentViewController:controller];
		popOver.delegate = self;
	} else {
		popOver.contentViewController = controller;
	}
	
	return popOver;
}

@end
