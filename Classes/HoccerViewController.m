//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#import "NSObject+DelegateHelper.h"
#import "NSString+StringWithData.h"

#import "HoccerViewController.h"
#import "HoccerAppDelegate.h"

#import "HoccerVcard.h"
#import "HoccerText.h"
#import "Preview.h"
#import "ContentContainerView.h"

#import "DesktopView.h"
#import "ReceivedContentViewController.h"
#import "SelectContentViewController.h"

#import "HelpScrollView.h"

#import "HoccerImage.h"
#import "HoccerText.h"
#import "HoccerVcard.h"
#import "HoccerContent.h"

#import "DesktopDataSource.h"
#import "FeedbackProvider.h"
#import "GesturesInterpreter.h"
#import "LocationController.h"

#import "HocItemData.h"
#import "StatusViewController.h"

#import "HoccingRulesIPhone.h"

@implementation HoccerViewController

@synthesize delegate; 
@synthesize helpViewController;
@synthesize locationController;
@synthesize gestureInterpreter;
@synthesize statusViewController;
@synthesize desktopData;


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	self.helpViewController = nil;
}

- (void)viewDidLoad {
	desktopView.delegate = self;
	gestureInterpreter.delegate = self;

	desktopData = [[DesktopDataSource alloc] init];
	desktopData.viewController = self;
		
	desktopView.shouldSnapToCenterOnTouchUp = YES;
	desktopView.dataSource = desktopData;
	
	hoccingRules = [[HoccingRulesIPhone alloc] init];
	
	[self.view insertSubview:statusViewController.view atIndex:1];
}

- (void)viewDidUnload {
}

- (void)dealloc {

	[desktopView release];	
	[desktopData release];
	[helpViewController release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark User Action

- (IBAction)selectContacts: (id)sender {}
- (IBAction)selectImage: (id)sender {}
- (IBAction)selectText: (id)sender {}
- (IBAction)toggleSelectContent: (id)sender {}

- (IBAction)toggleHelp: (id)sender {}

#pragma mark -
#pragma mark View Manipulation

- (void)resetPreview {
	[desktopView resetView];
}

- (void)presentReceivedContent:(HoccerContent*) hoccerContent {
	receivedContentViewController = [[ReceivedContentViewController alloc] initWithNibName:@"ReceivedContentView" bundle:nil];
	
	receivedContentViewController.delegate = self;
	[receivedContentViewController setHoccerContent: hoccerContent];
		
	[self presentModalViewController: receivedContentViewController animated:YES];	
    [self resetPreview];
}

- (HelpScrollView *)helpViewController {
	if (helpViewController == nil) {
		helpViewController = [[HelpScrollView alloc] init];
	}
	
	return helpViewController;
}


- (void)receivedViewContentControllerDidFinish:(ReceivedContentViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)setContentPreview: (HoccerContent *)content {
	if (![hoccingRules hoccerViewControllerMayAddAnotherView:self]) {
		return;
	}
	
	NSLog(@"setting content preview: %@", content);
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.viewOrigin = CGPointMake(50, 50);
	item.content = content;
	item.delegate = self;
	
	[desktopData addHocItem:item];
	[desktopView reloadData];
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	HoccerContent* content = [[[HoccerImage alloc] initWithUIImage:
								   [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease];
		
	[self setContentPreview: content];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ABPeoplePickerNavigationController delegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	ABRecordID contactId = ABRecordGetRecordID(person);
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef fullPersonInfo = ABAddressBookGetPersonWithRecordID(addressBook, contactId);
	
	HoccerContent* content = [[[HoccerVcard alloc] initWitPerson:fullPersonInfo] autorelease];
	[self setContentPreview: content];
	
	[self dismissModalViewControllerAnimated:YES];
	CFRelease(addressBook);
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property 
							  identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker 
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark GesturesInterpreter Delegate Methods

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter {
	NSLog(@"did detect catch");
	
	if (![hoccingRules hoccerViewControllerMayCatch:self]) {
		return;
	}
	
	[FeedbackProvider playCatchFeedback];
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.delegate = self;
	
	[desktopData addHocItem:item];
	[desktopView reloadData];
	
	[item downloadWithLocation:locationController.location gesture:@"distribute"];

}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter {
	if (![hoccingRules hoccerViewControllerMayThrow:self]) {
		return;
	}
	
	[[desktopData hocItemDataAtIndex:0] uploadWithLocation:locationController.location gesture:@"distribute"];
	
	[FeedbackProvider playThrowFeedback];
	[desktopView animateView: [desktopData viewAtIndex:0]];
	
	statusViewController.hocItemData = [desktopData hocItemDataAtIndex:0];
	[statusViewController showActivityInfo];
}


#pragma mark -
#pragma mark DesktopViewDelegate

- (void)desktopView:(DesktopView *)desktopView didRemoveView: (UIView *)view {
	HocItemData *item = [desktopData hocItemDataForView:view];
	if ([item hasActiveRequest]) {
		[item cancelRequest];	
	} else{
		[desktopData removeHocItem:item];
	}
}

- (void)desktopView: (DesktopView *)desktopView didSweepInView: (UIView *)view {
	if ([desktopData controllerHasActiveRequest]) {
		return;
	}
	
	HocItemData *item = [desktopData hocItemDataForView: view];
	[item downloadWithLocation:locationController.location gesture:@"pass"];
}

- (void)desktopView: (DesktopView *)desktopView didSweepOutView: (UIView *)view {
	if ([desktopData controllerHasActiveRequest]) {
		return;
	}
	
	HocItemData *item = [desktopData hocItemDataForView: view];
	[item uploadWithLocation:locationController.location gesture:@"pass"];
	
	statusViewController.hocItemData = item;
	[statusViewController showActivityInfo];
}

- (UIView *)desktopView: (DesktopView *)aDesktopView needsEmptyViewAtPoint: (CGPoint)point {
	if (![hoccingRules hoccerViewControllerMaySweepIn:self]) {
		return nil;
	}
	
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.delegate = self;
	
	[desktopData addHocItem:item];
	[desktopView reloadData];
	
	return item.contentView;
}

#pragma mark -
#pragma mark HocItemDataDelegate

- (void)hocItemWasSend: (HocItemData *)item {
	statusViewController.hocItemData = nil;
	
	[desktopData removeHocItem:item];
	[desktopView reloadData];
}

- (void)hocItemWasReceived: (HocItemData *)item {
	statusViewController.hocItemData = nil;

	[desktopView reloadData];
}

- (void)hocItemUploadFailed: (HocItemData *)item {
	item.viewOrigin = CGPointMake(200, 300);
	
	[desktopView reloadData];
}

- (void)hocItemUploadWasCanceled: (HocItemData *)item {
	statusViewController.hocItemData = nil;
	item.viewOrigin = CGPointMake(200, 300);
	
	[desktopView reloadData];
}

- (void)hocItemDownloadWasCanceled: (HocItemData *)item {
	statusViewController.hocItemData = nil;
	
	[desktopData removeHocItem:item];
	[desktopView reloadData];
}

- (void)hocItemDownloadFailed: (HocItemData *)item {
	statusViewController.hocItemData = nil;
	
	[desktopData removeHocItem:item];
	[desktopView reloadData];
}

- (void)hocItemWillStartDownload: (HocItemData *)item {
	statusViewController.hocItemData = item;
	[statusViewController showActivityInfo];
}

@end
