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
#import "HoccerMessageResolver.h"

#import "HoccingRulesIPhone.h"
#import "HistoryData.h"

@implementation HoccerViewController

@synthesize delegate; 
@synthesize helpViewController;
@synthesize locationController;
@synthesize gestureInterpreter;
@synthesize statusViewController;
@synthesize desktopData;
@synthesize defaultOrigin;
@synthesize hoccability;
@synthesize blocked;

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
	locationController.delegate = self;
	hoccability.text = [[NSNumber numberWithInteger:locationController.hoccability] stringValue];
	
	historyData = [[HistoryData alloc] init];
	self.defaultOrigin = CGPointMake(7, 22);
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[desktopView release];	
	[desktopData release];
	[locationController release];
	[gestureInterpreter release];
	[helpViewController release];
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

- (void)showDesktop {}

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
	if (![hoccingRules hoccerViewControllerMayCatch:self]) {
		return;
	}
	
	[FeedbackProvider playCatchFeedback];
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.delegate = self;
	item.viewOrigin = CGPointMake(desktopView.frame.size.width / 2 - item.contentView.frame.size.width / 2, 50);
	
	[desktopData addHocItem:item];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.fromValue = [NSValue valueWithCGPoint:
						   CGPointMake(desktopView.frame.size.width / 2 - item.contentView.frame.size.width / 2, 50)];
	
	[desktopView insertView:item.contentView atPoint: item.viewOrigin withAnimation:animation];
	
	[item downloadWithLocation:locationController.location gesture:@"catch"];

}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter {
	if (![hoccingRules hoccerViewControllerMayThrow:self]) {
		return;
	}

	statusViewController.hocItemData = [desktopData hocItemDataAtIndex:0];
	[[desktopData hocItemDataAtIndex:0] uploadWithLocation:locationController.location gesture:@"throw"];
	[FeedbackProvider playThrowFeedback];
	
	UIView *view = [desktopData viewAtIndex:0];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.duration = 0.2;
	animation.toValue = [NSValue valueWithCGPoint: CGPointMake(view.center.x, -200)];
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	
	[desktopView animateView: [desktopData viewAtIndex:0] withAnimation: animation];
	
}


#pragma mark -
#pragma mark DesktopViewDelegate

- (void)desktopView:(DesktopView *)desktopView didRemoveViewAtIndex: (NSInteger)index {
	HocItemData *item = [desktopData hocItemDataAtIndex:index];
	if ([item hasActiveRequest]) {
		[item cancelRequest];	
	} else{
		[desktopData removeHocItem:item];
	}
}

- (void)desktopView: (DesktopView *)desktopView didSweepInView: (UIView *)view {
	if ([desktopData hasActiveRequest]) {
		return;
	}
	
	HocItemData *item = [desktopData hocItemDataForView: view];
	[item downloadWithLocation:locationController.location gesture:@"sweepIn"];
}

- (void)desktopView: (DesktopView *)desktopView didSweepOutView: (UIView *)view {
	if ([desktopData hasActiveRequest]) {
		return;
	}
	
	HocItemData *item = [desktopData hocItemDataForView: view];
	[item uploadWithLocation:locationController.location gesture:@"sweepOut"];
	
	statusViewController.hocItemData = item;
}

- (BOOL)desktopView: (DesktopView *)aDesktopView needsEmptyViewAtPoint: (CGPoint)point {
	if (![hoccingRules hoccerViewControllerMaySweepIn:self]) {
		return NO;
	}
	
	HocItemData *item = [[[HocItemData alloc] init] autorelease];
	item.viewOrigin = CGPointMake(point.x - item.contentView.frame.size.width / 2, 
								  point.y - item.contentView.frame.size.height / 2);
	item.delegate = self;
	
	[desktopData addHocItem:item];
	[desktopView reloadData];
	
	return YES;
}

#pragma mark -
#pragma mark HocItemDataDelegate

- (void)hocItemWasSend: (HocItemData *)item {
	statusViewController.hocItemData = nil;
	[statusViewController setCompleteState];
	[historyData addContentToHistory:item];

	
	[desktopData removeHocItem:item];
	[desktopView reloadData];
}

- (void)hocItemWasReceived: (HocItemData *)item {
	statusViewController.hocItemData = nil;
//	[statusViewController hideActivityInfo];
	[historyData addContentToHistory:item];

	[desktopView reloadData];
}

- (void)hocItem: (HocItemData*) item uploadFailedWithError: (NSError *)error {
	[statusViewController setError:error];

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

- (void)hocItem: (HocItemData *)item downloadFailedWithError: (NSError *)error  {
	statusViewController.hocItemData = nil;
	[statusViewController setError:error];
	[desktopData removeHocItem:item];
	[desktopView reloadData];
}

- (void)hocItemWillStartDownload: (HocItemData *)item {
	statusViewController.hocItemData = item;
//	[statusViewController showActivityInfo];
}

#pragma mark -
#pragma mark LocationController Delegate Methods

- (void) locationControllerDidUpdateLocation: (LocationController *)controller {
	NSLog(@"hoccability: %d", controller.hoccability);
	
	if (controller.hoccability == 0) {
		blocked = YES;
	} else {
		blocked = NO;
	}

	hoccability.text = [[NSNumber numberWithInteger:controller.hoccability] stringValue];
	
	NSError *message = [controller messageForLocationInformation];
	if (![desktopData hasActiveRequest]) {
		if (message) {
			[statusViewController setLocationHint: message];			
		} else {
			[statusViewController setLocationHint: nil];
		}
	}
}


@end
