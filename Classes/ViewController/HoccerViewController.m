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
#import "ACAddressBookPerson.h"

#import "DesktopView.h"
#import "ReceivedContentViewController.h"

#import "HelpScrollView.h"

#import "HoccerImage.h"
#import "HoccerText.h"
#import "HoccerVcard.h"
#import "HoccerContent.h"

#import "DesktopDataSource.h"
#import "FeedbackProvider.h"
#import "GesturesInterpreter.h"
#import "LocationController.h"

#import "HoccerController.h"
#import "StatusViewController.h"

#import "HoccingRulesIPhone.h"
#import "HistoryData.h"

#import "SettingViewController.h"

@implementation HoccerViewController

@synthesize delegate; 
@synthesize helpViewController;
@synthesize locationController;
@synthesize gestureInterpreter;
@synthesize statusViewController;
@synthesize infoViewController;
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
	infoViewController.delegate = self;
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

- (SettingViewController *)helpViewController {
	if (helpViewController == nil) {
		helpViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
	}
	
	return helpViewController;
}

- (void)setContentPreview: (HoccerContent *)content {
	if (![hoccingRules hoccerViewControllerMayAddAnotherView:self]) {
		[desktopData removehoccerController: [desktopData hoccerControllerDataAtIndex:0]];
	}
	
	HoccerController *item = [[[HoccerController alloc] init] autorelease];
	item.viewOrigin = self.defaultOrigin;
	item.content = content;
	item.delegate = self;
	
	[desktopData addhoccerController:item];
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
	
	ACAddressBookPerson *addressBookPerson = [[ACAddressBookPerson alloc] initWithId: (ABRecordID) ABRecordGetRecordID(person)];
	[addressBookPerson release];
	
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
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
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
	HoccerController *item = [[[HoccerController alloc] init] autorelease];
	item.delegate = self;
	item.viewOrigin = CGPointMake(desktopView.frame.size.width / 2 - item.contentView.frame.size.width / 2, 110);
	
	[desktopData addhoccerController:item];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.fromValue = [NSValue valueWithCGPoint: CGPointMake(desktopView.frame.size.width / 2, 0)];
	animation.duration = 0.2;
	
	[desktopView insertView:item.contentView atPoint: item.viewOrigin withAnimation:animation];
	
	[item catchWithLocation:locationController.location];
}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter {
	if (![hoccingRules hoccerViewControllerMayThrow:self]) {
		return;
	}
	
	[FeedbackProvider playThrowFeedback];
	statusViewController.hoccerControllerData = [desktopData hoccerControllerDataAtIndex:0];
	[[desktopData hoccerControllerDataAtIndex:0] throwWithLocation:locationController.location];

	
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
	HoccerController *item = [desktopData hoccerControllerDataAtIndex:index];
	if ([item hasActiveRequest]) {
		[item cancelRequest];	
	} else{
		[desktopData removehoccerController:item];
	}
}

- (void)desktopView: (DesktopView *)desktopView didSweepInView: (UIView *)view {
	if ([desktopData hasActiveRequest]) {
		return;
	}
	
	[FeedbackProvider playSweepIn];
	HoccerController *item = [desktopData hoccerControllerDataForView: view];
	[item sweepInWithLocation: locationController.location];
}

- (void)desktopView: (DesktopView *)desktopView didSweepOutView: (UIView *)view {
	if ([desktopData hasActiveRequest]) {
		return;
	}
	
	[FeedbackProvider playSweepOut];
	HoccerController *item = [desktopData hoccerControllerDataForView: view];
	statusViewController.hoccerControllerData = item;

	[item sweepOutWithLocation:locationController.location];
}

- (BOOL)desktopView: (DesktopView *)aDesktopView needsEmptyViewAtPoint: (CGPoint)point {
	if (![hoccingRules hoccerViewControllerMaySweepIn:self]) {
		return NO;
	}
	
	HoccerController *item = [[[HoccerController alloc] init] autorelease];
	item.viewOrigin = CGPointMake(point.x - item.contentView.frame.size.width / 2, 
								  point.y - item.contentView.frame.size.height / 2);
	item.delegate = self;
	
	[desktopData addhoccerController:item];
	[desktopView reloadData];
	
	return YES;
}

#pragma mark -
#pragma mark HoccerControllerDataDelegate

- (void)hoccerControllerWasSent: (HoccerController *)item {
	statusViewController.hoccerControllerData = nil;
	[statusViewController setCompleteState];
	[historyData addContentToHistory:item];
	
	[desktopData removehoccerController:item];
	[desktopView reloadData];
}

- (void)hoccerControllerWasReceived: (HoccerController *)item {
	statusViewController.hoccerControllerData = nil;
	[statusViewController setCompleteState];
	[historyData addContentToHistory:item];

	[desktopView reloadData];
}

- (void)hoccerController: (HoccerController*) item uploadFailedWithError: (NSError *)error {
	[statusViewController setError:error];

	item.viewOrigin = self.defaultOrigin;
	[desktopView reloadData];
}

- (void)hoccerControllerUploadWasCanceled: (HoccerController *)item {
	statusViewController.hoccerControllerData = nil;
	item.viewOrigin = self.defaultOrigin;
	
	[desktopView reloadData];
}

- (void)hoccerControllerDownloadWasCanceled: (HoccerController *)item {
	statusViewController.hoccerControllerData = nil;
	
	[desktopData removehoccerController:item];
	[desktopView reloadData];
}

- (void)hoccerController: (HoccerController *)item downloadFailedWithError: (NSError *)error  {
	statusViewController.hoccerControllerData = nil;
	[statusViewController setError:error];
	[desktopData removehoccerController:item];
	[desktopView reloadData];
}

- (void)hoccerControllerWillStartDownload: (HoccerController *)item {
	statusViewController.hoccerControllerData = item;
}

- (void)hoccerControllerWasClosed:(HoccerController *)item {
	[desktopData removehoccerController:item];
	[desktopView reloadData];
}

#pragma mark -
#pragma mark LocationController Delegate Methods

- (void) locationControllerDidUpdateLocation: (LocationController *)controller {
	if (controller.hoccability == 0) {
		blocked = YES;
	} else {
		blocked = NO;
	}

	hoccability.text = [[NSNumber numberWithInteger:controller.hoccability] stringValue];
	
//	NSError *message = [controller messageForLocationInformation];
//	if (![desktopData hasActiveRequest]) {
//		if (message) {
//			[statusViewController setLocationHint: message];			
//		} else {
//			[statusViewController setLocationHint: nil];
//		}
//	}
}


@end
