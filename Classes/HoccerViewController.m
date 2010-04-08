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
#import "HocHistory.h"
#import "StatusViewController.h"

#import "HoccingRulesIPhone.h"

@implementation HoccerViewController

@synthesize delegate; 
@synthesize helpViewController;
@synthesize hoccerHistoryController;
@synthesize locationController;
@synthesize gestureInterpreter;
@synthesize statusViewController;
@synthesize desktopData;
@synthesize defaultOrigin;

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
	
	hoccerHistoryController = [[HocHistory alloc] init];
	
	[self.view insertSubview:statusViewController.view atIndex:1];
	self.defaultOrigin = CGPointMake(12, 42);
}

- (void)viewDidUnload {
}

- (void)dealloc {

	[desktopView release];	
	[desktopData release];
	[locationController release];
	[gestureInterpreter release];
	[helpViewController release];
	[hoccerHistoryController release];
	[statusViewController release];
	[hoccingRules release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark User Action

- (IBAction)selectContacts: (id)sender {}
- (IBAction)selectImage: (id)sender {}
- (IBAction)selectText: (id)sender {}
- (IBAction)showHistory: (id)sender {}
- (IBAction)toggleSelectContent: (id)sender {}
- (IBAction)toggleHistory: (id)sender {}
- (IBAction)toggleHelp: (id)sender {}

#pragma mark -
#pragma mark View Manipulation

- (HelpScrollView *)helpViewController {
	if (helpViewController == nil) {
		helpViewController = [[HelpScrollView alloc] init];
	}
	
	return helpViewController;
}

- (void)setContentPreview: (HoccerContent *)content {
	if (![hoccingRules hoccerViewControllerMayAddAnotherView:self]) {
		return;
	}
	
	NSLog(@"setting content preview: %@", content);
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.viewOrigin = self.defaultOrigin;
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
	
	UIView *view = [desktopData viewAtIndex:0];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.duration = 0.5;
	animation.toValue = [NSValue valueWithCGPoint: CGPointMake(view.center.x, -200)];
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	
	[desktopView animateView: [desktopData viewAtIndex:0] withAnimation: animation];
	
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

- (void)desktopView: (DesktopView *)aDesktopView needsEmptyViewAtPoint: (CGPoint)point {
	if (![hoccingRules hoccerViewControllerMaySweepIn:self]) {
		return;
	}
	
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.viewOrigin = CGPointMake(point.x - item.contentView.frame.size.width / 2, 
								  point.y - item.contentView.frame.size.height / 2);
	item.delegate = self;
	
	[desktopData addHocItem:item];
	[desktopView reloadData];
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
	item.viewOrigin = self.defaultOrigin;
	
	[desktopView reloadData];
}

- (void)hocItemUploadWasCanceled: (HocItemData *)item {
	statusViewController.hocItemData = nil;
	item.viewOrigin = self.defaultOrigin;
	
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
