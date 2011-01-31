//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <YAJLIOS/YAJLIOS.h>
#import "Hoccer.h"
#import "TransferController.h"

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

#import "DesktopDataSource.h"
#import "FeedbackProvider.h"
#import "GesturesInterpreter.h"

#import "ItemViewController.h"
#import "StatusViewController.h"

#import "HoccingRulesIPhone.h"
#import "HistoryData.h"

#import "SettingViewController.h"
#import "ConnectionStatusViewController.h"

#import "StatusBarStates.h"
#import "HoccerContentFactory.h"

#import "FileUploader.h"

@implementation HoccerViewController

@synthesize delegate; 
@synthesize helpViewController;
@synthesize gestureInterpreter;
@synthesize statusViewController;
@synthesize infoViewController;
@synthesize desktopData;
@synthesize defaultOrigin;
@synthesize hoccabilityLabel;
@synthesize blocked;


+ (void) initialize {
	NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	[[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile: filepath]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	self.helpViewController = nil;
}

- (void)viewDidLoad {
	self.blocked = YES;
	
	httpClient = [[HttpClient alloc] initWithURLString:@"http://api.hoccer.com/"];
	httpClient.target = self;
	[httpClient getURI:@"/iphone/status.json" success:@selector(httpConnection:didReceiveStatus:)];
	
	linccer = [[HCLinccer alloc] initWithApiKey:@"e101e890ea97012d6b6f00163e001ab0" secret:@"JofbFD6w6xtNYdaDgp4KOXf/k/s="];
	linccer.delegate = self;
	
	desktopView.delegate = self;
	gestureInterpreter.delegate = self;

	desktopData = [[DesktopDataSource alloc] init];
	desktopData.viewController = self;
		
	desktopView.shouldSnapToCenterOnTouchUp = YES;
	desktopView.dataSource = desktopData;
	
	historyData = [[HistoryData alloc] init];
	self.defaultOrigin = CGPointMake(7, 22);

	downloadController = [[TransferController alloc] init];
	downloadController.delegate = self;
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[desktopView release];	
	[desktopData release];
	[gestureInterpreter release];
	[helpViewController release];
	[statusViewController release];
	[hoccingRules release];
	[downloadController release];
	
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

- (void)httpConnection: (HttpConnection *)connection didReceiveStatus: (NSData *)data {
	NSDictionary *message = nil;
	@try {
		message = [data yajl_JSON];		
	}
	@catch (NSException * e) {}

	if ([[message objectForKey:@"status"] isEqualToString: @"update"]) {
		
		UIAlertView *view = [[UIAlertView alloc] initWithTitle:[message objectForKey:@"title"] 
													   message:[message objectForKey:@"message"]
													  delegate:self cancelButtonTitle:nil otherButtonTitles:@"Update", nil];
		[view show];
		[view release];
	
		[httpClient release]; httpClient = nil;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSURL *appStoreUrl = [NSURL URLWithString:@"http://itunes.apple.com/us/app/hoccer/id340180776?mt=8"];
	[[UIApplication sharedApplication] openURL: appStoreUrl];
}														
														
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
		[desktopData removeHoccerController: [desktopData hoccerControllerDataAtIndex:0]];
	}
	
	ItemViewController *item = [[[ItemViewController alloc] init] autorelease];
	item.viewOrigin = self.defaultOrigin;
	item.content = content;
	item.delegate = self;
	
	if ([content transferer]) {
		fileUploaded = NO;
		[downloadController addContentToDownloadQueue:[content transferer]];		
	}
		
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

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark GesturesInterpreter Delegate Methods

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter {
	if (![hoccingRules hoccerViewControllerMayCatch:self]) {
		return;
	}

	[infoViewController hideViewAnimated:YES];

	[FeedbackProvider playCatchFeedback];
	ItemViewController *item = [[[ItemViewController alloc] init] autorelease];
	item.delegate = self;
	item.viewOrigin = CGPointMake(desktopView.frame.size.width / 2 - item.contentView.frame.size.width / 2, 110);
	
	[desktopData addhoccerController:item];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.fromValue = [NSValue valueWithCGPoint: CGPointMake(desktopView.frame.size.width / 2, 0)];
	animation.duration = 0.2;
	
	[desktopView insertView:item.contentView atPoint: item.viewOrigin withAnimation:animation];

	[self willStartDownload:item];
	[linccer receiveWithMode:HCTransferModeOneToMany];
	
	[statusViewController setState:[ConnectionState state]];
	[statusViewController setUpdate:NSLocalizedString(@"Connecting..", nil)];
}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter {
	if (![hoccingRules hoccerViewControllerMayThrow:self]) {
		return;
	}
	
	[infoViewController hideViewAnimated:YES];
	
	[FeedbackProvider playThrowFeedback];
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	item.isUpload = YES;
	
	[linccer send:[self dictionaryToSend:item] withMode:HCTransferModeOneToMany];
	[statusViewController setState:[ConnectionState state]];
	[statusViewController setUpdate:NSLocalizedString(@"Connecting..", nil)];
	
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
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:index];
	if ([item hasActiveRequest]) {
		[item cancelRequest];	
	} else{
		[desktopData removeHoccerController:item];
	}
}

- (void)desktopView: (DesktopView *)desktopView didSweepInView: (UIView *)view {
	if ([desktopData hasActiveRequest]) {
		return;
	}
	[FeedbackProvider playSweepIn];
	[statusViewController setState:[ConnectionState state]];
	[infoViewController hideViewAnimated:YES];
	
	[statusViewController setState:[ConnectionState state]];
	[statusViewController setUpdate:NSLocalizedString(@"Connecting..", nil)];
	
	ItemViewController *item = [desktopData hoccerControllerDataForView: view];
	
	[self willStartDownload:item];
	
	[linccer receiveWithMode:HCTransferModeOneToOne];
}

- (void)desktopView: (DesktopView *)desktopView didSweepOutView: (UIView *)view {
	if ([desktopData hasActiveRequest]) {
		return;
	}
	
	[infoViewController hideViewAnimated:YES];
	[statusViewController setState:[ConnectionState state]];
	[statusViewController setUpdate:NSLocalizedString(@"Connecting..", nil)];
	[FeedbackProvider playSweepOut];
	
	ItemViewController *item = [desktopData hoccerControllerDataForView: view];
	item.isUpload = YES;
		
	[linccer send:[self dictionaryToSend: item] withMode:HCTransferModeOneToOne];	
}

- (BOOL)desktopView: (DesktopView *)aDesktopView needsEmptyViewAtPoint: (CGPoint)point {
	if (![hoccingRules hoccerViewControllerMaySweepIn:self]) {
		return NO;
	}
	
	ItemViewController *item = [[[ItemViewController alloc] init] autorelease];
	item.viewOrigin = CGPointMake(point.x - item.contentView.frame.size.width / 2, 
								  point.y - item.contentView.frame.size.height / 2);
	item.delegate = self;
	
	[desktopData addhoccerController:item];
	[desktopView reloadData];
	
	return YES;
}

- (void)willStartDownload: (ItemViewController *)item {
	item.isUpload = NO;
}
	 
#pragma mark -
#pragma mark HoccerControllerDataDelegate

- (void)hoccerControllerUploadWasCanceled: (ItemViewController *)item {
	item.viewOrigin = self.defaultOrigin;
	
	[desktopView reloadData];
}

- (void)hoccerControllerDownloadWasCanceled: (ItemViewController *)item {
	[desktopData removeHoccerController:item];
	[desktopView reloadData];
}

#pragma mark -
#pragma mark ItemViewController 
- (void)itemViewControllerWasClosed:(ItemViewController *)item {
	[desktopData removeHoccerController:item];
	[desktopView reloadData];
}

- (void)itemViewControllerSaveButtonWasClicked: (ItemViewController *)item; {
	[item.content whenReadyCallTarget:self selector:@selector(finishedSaving:) context: item];
	if ([item.content needsWaiting]) {
		[item.contentView showSpinner];
	}
	
	if ([item.content saveDataToContentStorage]) {
		return;
	}
	
	if (![item.content.interactionController presentOpenInMenuFromRect:CGRectNull inView:self.view animated:YES]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot handle content", nil) 
															message:NSLocalizedString(@"No installed program can handle this content type.", nil) 
														   delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
	}
}

- (void)finishedSaving: (ItemViewController *)item {
	[item.contentView hideSpinner];
	[item.contentView showSuccess];
}


#pragma mark -
#pragma mark TransferController Delegate

- (void) transferController:(TransferController *)controller didFinishTransfer:(id)object {		
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	
	if ([object isKindOfClass:[FileUploader class]]) {
		fileUploaded = YES;
	} else {
		[self showSuccess:item];
	}
		
	[item updateView];
}

- (void) transferController:(TransferController *)controller didUpdateProgress:(NSNumber *)progress forTransfer:(id)object {
	if (connectionEsteblished) {
		[statusViewController setProgressUpdate: [progress floatValue]];
	}
}

- (void) transferController:(TransferController *)controller didFailWithError:(NSError *)error forTransfer:(id)object {
	[statusViewController setError: error];
}

#pragma mark -
#pragma mark HCLinccerDelegate Methods

- (void) linccerDidRegister:(HCLinccer *)linccer {
	NSLog(@"ready for sharing");
	self.blocked = NO;
}

- (void)linccer:(HCLinccer *)linccer didFailWithError:(NSError *)error {
	connectionEsteblished = NO;
	[statusViewController setError:error];

	if ([error domain] != HoccerError) {
		return;
	}
	
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	
	if (item.isUpload) {
		item.viewOrigin = self.defaultOrigin;
	} else {
		[desktopData removeHoccerController:item];	
	}
	
	[desktopView reloadData];
}

- (void) linccer:(HCLinccer *)linncer didReceiveData:(NSArray *)data {	
	connectionEsteblished = YES;

	NSDictionary *firstPayload = [data objectAtIndex:0];
	NSArray *content = [firstPayload objectForKey:@"data"];
	
	HoccerContent *hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromDict:[content objectAtIndex:0]];
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	item.content = hoccerContent;
	item.content.persist = YES;
	
	if ([hoccerContent transferer]) {
		[downloadController addContentToDownloadQueue:[hoccerContent transferer]];		
	} else {
		[self showSuccess: item];
	}
	
	[desktopView reloadData];

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"openInPreview"] boolValue]) {
		[item.content.interactionController setDelegate: self];
		[item.content.interactionController presentPreviewAnimated:YES];
	}
}

- (void) linccer:(HCLinccer *)linccer didSendDataWithInfo:(NSDictionary *)info {
	connectionEsteblished = YES;
	
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	
	if (![item.content transferer] || fileUploaded) {
		[self showSuccess: item];
	}
		
	[historyData addContentToHistory:item];
	
	[desktopData removeHoccerController:item];
	[desktopView reloadData];
}

#pragma mark -
#pragma mark UIDocumentInteractionController Delegate Methods
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
}

#pragma mark -
#pragma mark Private Methods
- (NSDictionary *)dictionaryToSend: (ItemViewController *)item {
	NSDictionary *sender = [NSDictionary dictionaryWithObject:@"" forKey:@"client-id"];
	NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys: sender, @"sender", 
							 [NSArray arrayWithObject:[item.content dataDesctiption]], @"data", nil];	 
	
	NSLog(@"content %@", content);
	
	return content;
}

- (void)showSuccess: (ItemViewController *)item {
	[historyData addContentToHistory:item];		

	[statusViewController setState:[SuccessState state]];
	[statusViewController showMessage: NSLocalizedString(@"Success", nil) forSeconds: 4];
	
	connectionEsteblished = NO;
}

@end
