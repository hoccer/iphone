//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright Hoccer GmbH 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <YAJLIOS/YAJLIOS.h>
#import <CommonCrypto/CommonCryptor.h>
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
#import "NSData_Base64Extensions.h"

#import <SystemConfiguration/SystemConfiguration.h>

@interface HoccerViewController ()

- (void)handleError: (NSError *)error;
- (NSString *)obfuscatedUUID: (NSString *)uuid;

- (void)showNetworkError: (NSError *)error;
- (void)ensureViewIsHoccable;

@end

@implementation HoccerViewController

@synthesize delegate; 
@synthesize helpViewController;
@synthesize gestureInterpreter;
@synthesize statusViewController;
@synthesize infoViewController;
@synthesize desktopData;
@synthesize defaultOrigin;
@synthesize hoccabilityLabel;
@synthesize hoccabilityInfo;
@synthesize linccer;

+ (void) initialize {
	NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	[[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile: filepath]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	self.helpViewController = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(fetchStatusUpdate) userInfo:nil repeats:NO];
	
	linccer = [[HCLinccer alloc] initWithApiKey:API_KEY secret:SECRET sandboxed: USES_SANDBOX];
	linccer.delegate = self;
	
	desktopView.delegate = self;
	gestureInterpreter.delegate = self;

	desktopData = [[DesktopDataSource alloc] init];
	desktopData.viewController = self;
		
	desktopView.shouldSnapToCenterOnTouchUp = YES;
	desktopView.dataSource = desktopData;
	
	historyData = [[HistoryData alloc] init];
	self.defaultOrigin = CGPointMake(7, 22);

	transferController = [[TransferController alloc] init];
	transferController.delegate = self;
	
	statusViewController.delegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(networkChanged:) 
												 name:@"NetworkConnectionChanged" 
											   object:nil];
}


- (void)fetchStatusUpdate {
	httpClient = [[HttpClient alloc] initWithURLString:@"http://api.hoccer.com"];
	httpClient.target = self;
	[httpClient getURI:@"/iphone/status2.json" success:@selector(httpConnection:didReceiveStatus:)];
}

- (void)viewDidUnload {
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
	linccer.latency = connection.roundTripTime;
	[linccer updateEnvironment];
	
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
    connectionEstablished = NO;
    
	if (![hoccingRules hoccerViewControllerMayAddAnotherView:self]) {
		[desktopData removeHoccerController: [desktopData hoccerControllerDataAtIndex:0]];
	}
	
	if (!content.readyForSending) {
		[self showHud];
	}
	
	ItemViewController *item = [[[ItemViewController alloc] init] autorelease];
	item.viewOrigin = self.defaultOrigin;
	item.content = content;
	item.delegate = self;
	
	if ([[content transferer] isKindOfClass:[FileUploader class]]) {
		item.isUpload = YES;
        fileUploaded = NO;
        
        for (id transferer in [content transferers]) {
            [transferController addContentToTransferQueue: transferer];
        }
	}
		
	[desktopData addhoccerController:item];
	[desktopView reloadData];
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissModalViewControllerAnimated:YES];
   	
	HoccerContent* content = [[[HoccerImage alloc] initWithUIImage:
								   [info objectForKey: UIImagePickerControllerOriginalImage]] autorelease];
	
	[self setContentPreview: content];
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
	if ([transferController hasTransfers]) {
		[transferController cancelDownloads];	
	} else{
		[desktopData removeHoccerController:item];
	}
}

- (void)desktopView: (DesktopView *)desktopView didSweepInView: (UIView *)view {	
	if ([self.linccer isLinccing]) {
		return;
	}
	
	[FeedbackProvider playSweepIn];
	[infoViewController hideViewAnimated:YES];
	
	[statusViewController setState:[ConnectionState state]];
	[statusViewController setUpdate:NSLocalizedString(@"Connecting..", nil)];
	
	ItemViewController *item = [desktopData hoccerControllerDataForView: view];
	
	[self willStartDownload:item];
	
	[linccer receiveWithMode:HCTransferModeOneToOne];
}

- (void)desktopView: (DesktopView *)desktopView didSweepOutView: (UIView *)view {
	if ([linccer isLinccing]) {
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

#pragma mark -
#pragma mark Connection Status View Controller Delegates
- (void) connectionStatusViewControllerDidCancel:(ConnectionStatusViewController *)controller {
	connectionEstablished = NO;
    
	BOOL isConnecting = [linccer isLinccing] || [transferController hasTransfers];
	if ([desktopData count] == 0 || !isConnecting) {
		return;
		
	}
	[linccer cancelAllRequest];

	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	if (item.isUpload) {
		item.viewOrigin = self.defaultOrigin;
	} else {
		[desktopData removeHoccerController:item];	
		[transferController cancelDownloads];
	}

	[desktopView reloadData];
}

#pragma mark -
#pragma mark ItemViewController 

- (void)willStartDownload: (ItemViewController *)item {
	item.isUpload = NO;
}

- (void)itemViewControllerWasClosed:(ItemViewController *)item {
	[transferController cancelDownloads];
	
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

- (void)transferController:(TransferController *)controller didFinishTransfer:(id)object {
    [self ensureViewIsHoccable];
    
	if ([desktopData count] == 0) {
		return;
	}
    
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	
	if (!item.isUpload) {
        [item updateView];
	}

}


- (void) transferControllerDidFinishAllTransfers:(TransferController *)controller {		
	[self ensureViewIsHoccable];

	if ([desktopData count] == 0) {
		return;
	}
    
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	
	if (item.isUpload) {
		fileUploaded = YES;
		if (connectionEstablished) {
			[self showSuccess:item];
		}
	} else {
		[self showSuccess:item];
	}
}

- (void) transferController:(TransferController *)controller didUpdateTotalProgress:(NSNumber *)progress {
	if (connectionEstablished) {
		[statusViewController setProgressUpdate: [progress floatValue]];
	}
}

- (void) transferController:(TransferController *)controller didFailWithError:(NSError *)error forTransfer:(id)object {
	[self handleError: error];
}

- (void) transferController:(TransferController *)controller didPrepareContent: (id)object {
	[self hideHUD];
}

#pragma mark -
#pragma mark HCLinccerDelegate Methods

- (void)linccer:(HCLinccer *)linccer didUpdateEnvironment:(NSDictionary *)quality {
	[self hideHUD];

	[self ensureViewIsHoccable];
}

- (void)linccer:(HCLinccer *)linccer didFailWithError:(NSError *)error {
	connectionEstablished = NO;
	[self handleError:error];
}

- (void) linccer:(HCLinccer *)linncer didReceiveData:(NSArray *)data {	
	[self ensureViewIsHoccable];
	
	connectionEstablished = YES;

	NSDictionary *firstPayload = [data objectAtIndex:0];
	NSArray *content = [firstPayload objectForKey:@"data"];
	
	HoccerContent *hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromDict:[content objectAtIndex:0]];
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	item.content = hoccerContent;
	item.content.persist = YES;
	
	if ([hoccerContent transferer]) {
        for (id transferer in [hoccerContent transferers]) {
            [transferController addContentToTransferQueue: transferer];		
        }
	} else {
		[self showSuccess: item];
	}
	
	[desktopView reloadData];

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"openInPreview"] boolValue]) {
		[item.content.interactionController setDelegate: self];
		[item.content.interactionController presentPreviewAnimated:YES];
	}
}

- (void) linccer:(HCLinccer *)linccer didSendData: (NSArray *)info {
	[self ensureViewIsHoccable];
	connectionEstablished = YES;
	
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	
	if (![[item.content transferer] isKindOfClass: [FileUploader class]] || fileUploaded) {
		[self showSuccess: item];
	}
}

#pragma mark -
#pragma mark UIDocumentInteractionController Delegate Methods
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
}

- (void)networkChanged: (NSNotification *)notification {
	[linccer updateEnvironment];
}

#pragma mark -
#pragma mark Private Methods
- (NSDictionary *)dictionaryToSend: (ItemViewController *)item {
	NSDictionary *sender = [NSDictionary dictionaryWithObject:[self obfuscatedUUID:linccer.uuid] forKey:@"client-id"];
	NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys: sender, @"sender", 
							 [NSArray arrayWithObject:[item.content dataDesctiption]], @"data", nil];
	
	return content;
}

- (void)handleError: (NSError *)error {
	if (error == nil) {
		[statusViewController hideStatus];
		return;
	}
	
	if ([[error domain] isEqual:NSURLErrorDomain]) {
		[statusViewController hideStatus];
		[self showNetworkError:error];
	} else if ([[error domain] isEqual:@"HttpErrorDomain"] && 
					[[[error userInfo] objectForKey:@"HttpClientErrorURL"] rangeOfString:@"environment"].location != NSNotFound) {
		[statusViewController hideStatus];
		[self showNetworkError:error];		
	} else {
		[statusViewController setError:error];
	}

	if ([desktopData count] == 0) {
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

- (void)showSuccess: (ItemViewController *)item {
	[historyData addContentToHistory:item];		
    
	if (item.isUpload) {
		[desktopData removeHoccerController:item];
		[desktopView reloadData];
	} else {
		[item updateView];
	}
	
	[statusViewController setState:[SuccessState state]];
	[statusViewController showMessage: NSLocalizedString(@"Success", nil) forSeconds: 4];
	
	connectionEstablished = NO;
}

- (void)showNetworkError: (NSError *)error {	
	desktopView.userInteractionEnabled = NO;
	linccer.environmentUpdateInterval = 5;
	
	if (errorView == nil) {
		NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ErrorView" owner:self options:nil];
		errorView = [[views objectAtIndex:0] retain];
		[desktopView insertSubview:errorView atIndex:0];
	}
	
	BOOL reachable = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate networkReachable];
	if ([[error domain] isEqual:NSURLErrorDomain] && !reachable) {
		((UILabel *)[errorView viewWithTag:2]).text = NSLocalizedString(@"You must connect to a Wi-Fi or cellular data network to use Hoccer.", nil);
	} else {
		((UILabel *)[errorView viewWithTag:2]).text = NSLocalizedString(@"The Hoccer Server cannot response to your request. Try again leter.", nil);
	}
	
	[self hideHUD];
}

- (void)ensureViewIsHoccable {	
	desktopView.userInteractionEnabled = YES;
	linccer.environmentUpdateInterval = 25;

	if (errorView != nil) {
		[errorView removeFromSuperview];
		[errorView release]; 
		errorView = nil;
	}
}

- (void)showHud {
	[self showHudWithMessage:NSLocalizedString(@"Preparing..", nil)];
}

- (void)showHudWithMessage: (NSString *)message {
	if (hud == nil) {
		hud = [[MBProgressHUD alloc] initWithView:self.view];
		[self.view addSubview:hud];
	}
	
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = message;

	[hud show:YES];
}

- (void)hideHUD {
	[hud hide:YES];
}

- (NSString *)obfuscatedUUID: (NSString *)uuid {
	unsigned char hashedChars[32];
	CC_SHA256([uuid UTF8String],
			  [uuid lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 
			  hashedChars);
	NSData * hashedData = [NSData dataWithBytes:hashedChars length:32];
	
	return [hashedData asBase64EncodedString];
}


- (void)dealloc {
	[hoccabilityInfo release];
	[desktopView release];	
	[desktopData release];
	[gestureInterpreter release];
	[helpViewController release];
	[statusViewController release];
	[hoccingRules release];
	[transferController release];
	[hud release];
	
	[super dealloc];
}

@end
