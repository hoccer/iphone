//
//  HoccerViewControlleriPad.m
//  Hoccer
//
//  Created by Robert Palmer on 23.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.

#import "HoccerViewControlleriPad.h"
#import "DragAndDropViewController.h"
#import "DesktopViewController.h"
#import "ReceivedContentViewController.h"
#import "Preview.h"
#import "NSObject+DelegateHelper.h"

#import "HoccerContent.h"
#import "HoccerImage.h"
#import "HoccerDataiPad.h"

#import "DesktopDataSource.h"


@interface HoccerViewControlleriPad () 

@property (retain) UIPopoverController *popOver;
- (UIPopoverController *)popOverWithController: (UIViewController*)controller;
- (DragAndDropViewController *)createDragAndDropControllerForContent: (id <HoccerContent>) content;

@end


@implementation HoccerViewControlleriPad
@synthesize popOver;

- (void)viewDidLoad {
	[super viewDidLoad];
	desktopData = [[DesktopDataSource alloc] init];
	
	self.previewViewController.shouldSnapBackOnTouchUp = NO;
	desktopViewController.shouldSnapToCenterOnTouchUp = NO;
	desktopViewController.dataSource = desktopData;
	[desktopViewController reloadData];
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

- (void)setContentPreview: (id <HoccerContent>)content {
	[desktopData addController: [self createDragAndDropControllerForContent: content]];
	[desktopViewController reloadData];


//	[self.previewViewController.view removeFromSuperview];
//	Preview *contentView = [content thumbnailView];
//	CGFloat xOrigin = (self.view.frame.size.width - contentView.frame.size.width) / 2;
//	
//	[backgroundView insertSubview: contentView atIndex: 1];
//	[self.view setNeedsDisplay];
//	self.previewViewController.view = contentView;	
//	
//	self.previewViewController.origin = CGPointMake(900, backgroundView.frame.size.height * 0.3);
//	
//	[UIView beginAnimations:@"previewSlideIn" context:nil];
//	self.previewViewController.origin = CGPointMake(xOrigin, backgroundView.frame.size.height * 0.3);
//	
//	[UIView setAnimationDuration: 0.4];
//	[UIView commitAnimations];
}

- (void)presentReceivedContent:(id <HoccerContent>) content{
	NSLog(@"content: %@", content);
	
	[desktopViewController.feedback addSubview: [content view]];
	UIDocumentInteractionController *interactionController = [(HoccerDataiPad *)content interactionController];
	interactionController.delegate = self;
	
	for (UIGestureRecognizer *gestureRecognizer in interactionController.gestureRecognizers) {
		[desktopViewController.feedback addGestureRecognizer: gestureRecognizer];
	}
	
	UIView *someView = [[[UIView alloc] initWithFrame:CGRectMake(300, 300, 150, 150)] autorelease];
	someView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:someView];
	desktopViewController.feedback = someView;
	
	self.allowSweepGesture = YES;
}

- (UIViewController* )documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
}

#pragma mark -
#pragma mark UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	id <HoccerContent> content = [[[HoccerImage alloc] initWithUIImage:
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

- (DragAndDropViewController *)createDragAndDropControllerForContent: (id <HoccerContent>) content {
	Preview *contentView = [content thumbnailView];
	
	DragAndDropViewController *dragViewController = [[DragAndDropViewController alloc] init];
	dragViewController.view = contentView;	
	dragViewController.origin = CGPointMake(300, 300);
	dragViewController.delegate = self;
	
	return [dragViewController autorelease];
}

- (IBAction)dragAndDropViewControllerWillBeDismissed: (UIViewController *)controller {
	[desktopData removeController:controller];
	[desktopViewController reloadData];
}



@end
