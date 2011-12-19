//
//  HoccerViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright Hoccer GmbH 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <YAJLiOS/YAJL.h>
#import <CommonCrypto/CommonCryptor.h>
#import "Hoccer.h"

#import "TransferController.h"
#import "NSObject+DelegateHelper.h"
#import "NSString+StringWithData.h"
#import "Crypto.h"

#import "HoccerViewController.h"
#import "HoccerAppDelegate.h"

#import "HoccerVcard.h"
#import "HoccerText.h"
#import "HoccerPasteboard.h"
#import "HoccerMusic.h"
#import "Preview.h"
#import "ContentContainerView.h"

#import "DesktopView.h"
#import "ReceivedContentViewController.h"

#import "HelpScrollView.h"

#import "DesktopDataSource.h"
#import "FeedbackProvider.h"
#import "GesturesInterpreter.h"

#import "ItemViewController.h"
#import "StatusViewController.h"

#import "HoccingRulesIPhone.h"
#import "HoccingRulesIPad.h"
#import "HistoryData.h"

#import "SettingViewController.h"
#import "ConnectionStatusViewController.h"

#import "StatusBarStates.h"
#import "HoccerContentFactory.h"

#import "FileUploader.h"
#import "NSData_Base64Extensions.h"

#import "ImageSelectViewController.h"
#import "ContactSelectViewController.h"
#import "HocletSelectViewController.h"


#import <SystemConfiguration/SystemConfiguration.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaItemCollection-Utils.h"
#import <AVFoundation/AVFoundation.h>

@interface HoccerViewController ()
@property (retain, nonatomic) ItemViewController *sendingItem;

- (void)showNetworkError: (NSError *)error;
- (void)ensureViewIsHoccable;

- (void)clientNameChanged: (NSNotification *)notification;
- (id <Cryptor>)currentCryptor;

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
@synthesize sendingItem;

+ (void) initialize {
	NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	
    NSMutableDictionary *defauts = [NSMutableDictionary dictionaryWithContentsOfFile: filepath];
    [defauts setObject:[UIDevice currentDevice].name forKey:@"clientName"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defauts];
    
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
    [self clientNameChanged:nil];	
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(clientNameChanged:) 
                                                 name:@"clientNameChanged" 
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(encryptionChanged:) 
                                                 name:@"encryptionChanged" 
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(encryptionError:) 
                                                 name:@"encryptionError" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(encryptionNotEnabled:) 
                                                 name:@"encryptionNotEnabled" 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(noPublicKey:) 
                                                 name:@"noPublicKey" 
                                               object:nil];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(desktopLongPressed:)];

    [desktopView addGestureRecognizer:longPress];
    [longPress release];
    
    cipherNeeded = YES;
    encryptionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"encryption"];
}

- (void)viewDidAppear:(BOOL)animated{
    [self becomeFirstResponder];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Fetching Status from Server
- (void)fetchStatusUpdate {
	httpClient = [[HttpClient alloc] initWithURLString:@"http://api.hoccer.com"];
	httpClient.target = self;
	[httpClient getURI:@"/iphone/status2.json" success:@selector(httpConnection:didReceiveStatus:)];
}

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
        
        view.tag = 1;
		[view show];
		[view release];
	}
    
    [httpClient release]; httpClient = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1){
        NSURL *appStoreUrl = [NSURL URLWithString:@"http://itunes.apple.com/us/app/hoccer/id340180776?mt=8"];
        [[UIApplication sharedApplication] openURL: appStoreUrl];
    }
    else if(alertView.tag == 2){
        if (buttonIndex == 1){
            [self showMediaPicker];
        }
    }
}

#pragma mark -
#pragma mark Content Select Controller Delegate
- (void)contentSelectController:(id)controller didSelectContent:(HoccerContent *)content {
    [self dismissContentSelectViewController];
    [self setContentPreview:content];
}

- (void)contentSelectControllerDidCancel:(id)controller {
    [self dismissContentSelectViewController];
}

#pragma mark -
#pragma mark Presenting Content Selector View
- (void)presentContentSelectViewController: (id <ContentSelectController>)controller {}
- (void)dismissContentSelectViewController {}


#pragma mark -
#pragma mark User Action

- (IBAction)selectContacts: (id)sender {
    UIActionSheet *contactChooser = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Choose Contact", nil),NSLocalizedString(@"My Contact", nil), nil];
    contactChooser.tag = 2;
    contactChooser.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [contactChooser showInView:self.view];
    [contactChooser release];
}

-(IBAction)selectContact:(id)sender {
    ContactSelectViewController *controller = [[ContactSelectViewController alloc] init];
    controller.delegate = self;
    [self presentContentSelectViewController:controller];
    [controller release];
}

-(IBAction)selectMyContact:(id)sender {
    
    ABRecordID ownContact = [[NSUserDefaults standardUserDefaults] integerForKey:@"uservCardRef"];
    if (ownContact == 0){
        UIAlertView *contactAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Please set contact", nil) message:NSLocalizedString(@"Please select your own contact.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [contactAlert show];
        [contactAlert release];
        ContactSelectViewController *controller = [[ContactSelectViewController alloc] init];
        controller.delegate = self;
        controller.settingOwnContact = YES;
        [self presentContentSelectViewController:controller];
        [controller release];
    }
    else {
        ContactSelectViewController *controller = [[ContactSelectViewController alloc] init];
        controller.delegate = self;
        [controller choosePersonByID:ownContact];
        [controller release];
    }

    
}
- (IBAction)selectImage: (id)sender {
    ImageSelectViewController *controller = [[ImageSelectViewController alloc] init];
    controller.delegate = self;
    [self presentContentSelectViewController:controller];
	[controller release];
}

- (IBAction)selectText: (id)sender {    
	HoccerContent* content = [[[HoccerText alloc] init] autorelease];
	[self setContentPreview: content];
}

- (IBAction)selectCamera: (id)sender {
    ImageSelectViewController *controller = [[ImageSelectViewController alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera];
    controller.delegate = self;
    [self presentContentSelectViewController:controller];
    
	[controller release];
}

- (IBAction)selectMedia: (id)sender {
    
    UIActionSheet *mediaChooser;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        mediaChooser = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo/Video", nil), NSLocalizedString(@"Choose Photo/Video", nil),NSLocalizedString(@"Choose Music", nil), nil];
    }
    else {
        mediaChooser = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles: NSLocalizedString(@"Choose Photo/Video", nil),NSLocalizedString(@"Choose Music", nil), nil];
    }
    mediaChooser.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    mediaChooser.tag = 1;
    [mediaChooser showInView:self.view];
    [mediaChooser release];
}

- (IBAction)selectMusic:(id)sender {
    
    UIAlertView *musicAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Converting songs can take several minutes, please be patient", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    musicAlert.tag = 2;
    [musicAlert show];
    [musicAlert release];
}

- (IBAction)selectHoclet: (id)sender {
    HocletSelectViewController *controller = [[HocletSelectViewController alloc] initWithNibName:@"HocletSelectViewController" bundle:nil];
    controller.delegate = self;
    
    [self presentContentSelectViewController:controller];
    [controller release];
}

- (IBAction)selectPasteboard: (id)sender {

    HoccerPasteboard* content = [[[HoccerPasteboard alloc] init] autorelease];
    if (content != nil){
        [self setContentPreview: [content returnPastedContent]];
    }
    else {
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Pasteboard content could not be read", nil) forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"Pasteboard failed" code:666 userInfo:userInfo];
        [self handleError:error];

    }

}

- (IBAction)showHistory: (id)sender {}
- (IBAction)toggleSelectContent: (id)sender {}
- (IBAction)toggleHistory: (id)sender {}
- (IBAction)toggleHelp: (id)sender {}

- (void)showDesktop {}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0: {
                    [self checkAndPerformSelector:@selector(selectCamera:) withObject:self];
                    break;
                }
                case 1: {
                    [self checkAndPerformSelector:@selector(selectImage:) withObject:self];
                    break;
                }
                case 2: {
                    
                    UIAlertView *musicAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Converting songs can take several minutes, please be patient", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    musicAlert.tag = 2;
                    [musicAlert show];
                    [musicAlert release];
                    
                }
                default: {
                    break;
                }
            }
        }
        else {
            switch (buttonIndex) {
                case 0: {
                    [self checkAndPerformSelector:@selector(selectImage:) withObject:self];
                    break;
                }
                case 1: {
                    
                    UIAlertView *musicAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Converting songs can take several minutes, please be patient", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    musicAlert.tag = 2;
                    [musicAlert show];
                    [musicAlert release];
                    
                }
                    
                default: {
                    break;
                }
            }
            
        }
    }
    else if (actionSheet.tag == 2) {
        switch (buttonIndex) {
            case 0: {
                ContactSelectViewController *controller = [[ContactSelectViewController alloc] init];
                controller.delegate = self;
                [self presentContentSelectViewController:controller];
                [controller release];
                break;
            }
            case 1: {
                ABRecordID ownContact = [[NSUserDefaults standardUserDefaults] integerForKey:@"uservCardRef"];
                if (ownContact == 0){
                    UIAlertView *contactAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Please set contact", nil) message:NSLocalizedString(@"Please select your own contact.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    [contactAlert show];
                    [contactAlert release];
                    ContactSelectViewController *controller = [[ContactSelectViewController alloc] init];
                    controller.delegate = self;
                    controller.settingOwnContact = YES;
                    [self presentContentSelectViewController:controller];
                    [controller release];
                    break;
                }
                else {
                    ContactSelectViewController *controller = [[ContactSelectViewController alloc] init];
                    controller.delegate = self;
                    [controller choosePersonByID:ownContact];
                    [controller release];
                    [self toggleSelectContent:nil];
                    break;
                }
            }
        }
        
    }
}

- (void)showMediaPicker {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = NO;
    mediaPicker.prompt = NSLocalizedString(@"Select a song", nil);
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        [self presentModalViewController:mediaPicker animated:YES];
    }   
    else {
        musicPopOverController = [[UIPopoverController alloc]initWithContentViewController:mediaPicker];
        BOOL isPortrait = UIDeviceOrientationIsPortrait(self.interfaceOrientation);
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            if (isPortrait) {
                [musicPopOverController presentPopoverFromRect:CGRectMake(248, 953, 49, 49) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            }
            else {
                [musicPopOverController presentPopoverFromRect:CGRectMake(380, 698, 49, 49) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            }
        }
        else {
            if (isPortrait) {
                [musicPopOverController presentPopoverFromRect:CGRectMake(198, 953, 49, 49) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            }
            else {
                [musicPopOverController presentPopoverFromRect:CGRectMake(325, 698, 49, 49) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            }
            
        }
    }
    [mediaPicker release];

}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    if (mediaItemCollection) {
        
        MPMediaItem *song = [mediaItemCollection firstMediaItem];
        
        HoccerContent *content = [[[HoccerMusic alloc]initWithMediaItem:song]autorelease];
        [self setContentPreview:content];
        
    }
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        [self dismissModalViewControllerAnimated:YES];
        [self showDesktop];
    }
    else {
        [musicPopOverController dismissPopoverAnimated:YES];
        [self showDesktop];
    }

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
    [statusViewController hideViewAnimated:NO];
    connectionEstablished = NO;
    content.cryptor = [self currentCryptor];
        
    [content viewDidLoad];
    
	if (![hoccingRules hoccerViewControllerMayAddAnotherView:self]) {
		[desktopData removeHoccerController: [desktopData hoccerControllerDataAtIndex:0]];
	}
	
	if (!content.readyForSending) {
		[self showHudWithMessage:NSLocalizedString(@"Preparing Content...",nil)];
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
	} else {
        fileUploaded = YES;
    }
		
	[desktopData addhoccerController:item];
	[desktopView reloadData];
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
    
    self.sendingItem = nil;
}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter {
	if (![hoccingRules hoccerViewControllerMayThrow:self]) {
		return;
	}
    
    if (encryptionEnabled && !clientSelected && [[NSUserDefaults standardUserDefaults] boolForKey:@"sendPassword"]){
        
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Please select a client for auto key transmission", nil) forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"Encryption Error" code:700 userInfo:userInfo];
        [statusViewController setError:error];
        return;
        
    }
	
	[infoViewController hideViewAnimated:YES];
	
	[FeedbackProvider playThrowFeedback];
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
    self.sendingItem = item;
    item.content.cryptor = [self currentCryptor];
    
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
    
    [desktopData removeHoccerController:item];
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
    self.sendingItem = nil;
}

- (void)desktopView: (DesktopView *)desktopView didSweepOutView: (UIView *)view {
	if ([linccer isLinccing]) {
		return;
	}
    
    if (encryptionEnabled && !clientSelected && [[NSUserDefaults standardUserDefaults] boolForKey:@"sendPassword"]){

        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Please select a client for auto key transmission", nil) forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"Encryption Error" code:700 userInfo:userInfo];
        [statusViewController setError:error];
        NSLog(@"Data on Desktop; %d",desktopData.count);
        [desktopView reloadData];
        return;

    }
    
    
	[FeedbackProvider playSweepOut];
	
	[infoViewController hideViewAnimated:YES];
	[statusViewController setState:[ConnectionState state]];
	[statusViewController setUpdate:NSLocalizedString(@"Connecting..", nil)];
	
	ItemViewController *item = [desktopData hoccerControllerDataForView: view];
    self.sendingItem = item;
    item.content.cryptor = [self currentCryptor];
	item.isUpload = YES;
		
	[linccer send:[self dictionaryToSend: item] withMode:HCTransferModeOneToOne];	
    
    [desktopData removeHoccerController:self.sendingItem];
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
    
    if (![linccer isLinccing] && ![transferController hasTransfers]) {
        return;
    }
    
	[linccer cancelAllRequest];

	if (self.sendingItem) {
		self.sendingItem.viewOrigin = self.defaultOrigin;
        [desktopData addhoccerController:self.sendingItem];
        [desktopView reloadData];
        
        self.sendingItem = nil;
	} else {
        if ([desktopData count] == 1){
            ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];

            [desktopData removeHoccerController:item];	
            [transferController cancelDownloads];
        }
        else {
            for (int i=0;i<[desktopData count];i++){
                ItemViewController *item = [desktopData hoccerControllerDataAtIndex:i];
                if (item.content == nil){
                    [desktopData removeHoccerController:item];
                    [transferController cancelDownloads];
                }
            }
        }
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
	
	if (![item.content presentOpenInViewController:self]) {
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
    
    fileUploaded = YES;
    
    if (connectionEstablished) {
        if (self.sendingItem) {
            [self showSuccess:self.sendingItem];
        } else {
            ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
            [self showSuccess:item];
            cipherNeeded = YES;
        }
    }
}

- (void) transferController:(TransferController *)controller didUpdateTotalProgress:(NSNumber *)progress {
	if (connectionEstablished) {
		[statusViewController setProgressUpdate: [progress floatValue]];
	}
}

- (void) transferController:(TransferController *)controller didFailWithError:(NSError *)error forTransfer:(id)object {
	[self handleError: error];
    [self hideHUD];
    cipherNeeded = YES;
}

- (void) transferController:(TransferController *)controller didPrepareContent: (id)object {
	[self hideHUD];
    
    if ([object isKindOfClass:[HoccerMusic class]]){
        HoccerMusic *tempMusic = (HoccerMusic *)object;
        if (tempMusic.thumb && tempMusic.data ==nil){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Song could not be loaded", nil) forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"Song failed" code:796 userInfo:userInfo];
            [self handleError:error];
        }
    }
    cipherNeeded = NO;
}

#pragma mark -
#pragma mark HCLinccerDelegate Methods

- (void)linccer:(HCLinccer *)linccer didUpdateEnvironment:(NSDictionary *)quality {
    if(![hud.labelText isEqualToString:NSLocalizedString(@"Preparing Content...",nil)]){
        [self hideHUD];
    }

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
	
    if ([desktopData count] > 0) {
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
    }
}

- (void) linccer:(HCLinccer *)linccer didSendData: (NSArray *)info {
	[self ensureViewIsHoccable];
	connectionEstablished = YES;

    if (self.sendingItem && fileUploaded) {
        [self showSuccess:self.sendingItem];
    }
}

- (void) linccer:(HCLinccer *)linccer keyHasChangedForClientName:(NSString *)client{
    UIAlertView *keyAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Public key changed", nil) message:[NSString stringWithFormat:NSLocalizedString(@"The name or the public key of %@ has changed, please make shure you trust this client and be aware that this transaction could be attacked with a man-in-the-middle-attack",nil),client] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [keyAlert show];
    [keyAlert release];
}

#pragma mark -
#pragma mark LongTouch Detector

-(void)desktopLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if([hoccingRules hoccerViewControllerMayAddAnotherView:self]){
            CGPoint location = [gestureRecognizer locationInView:desktopView ];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *pasteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Paste", nil) action:@selector(selectPasteboard:)];
            [menuController setMenuItems:[NSArray arrayWithObject:pasteMenuItem]];
            [menuController setTargetRect:CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:desktopView];
            [menuController setMenuVisible:YES animated:YES];
            [pasteMenuItem release];
        }
    }    
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}


#pragma mark -
#pragma mark UIDocumentInteractionController Delegate Methods
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
}

#pragma mark -
#pragma mark Notifications
- (void)networkChanged: (NSNotification *)notification {
	[linccer reactivate];
}

- (void)clientNameChanged: (NSNotification *)notification {
    NSMutableDictionary *userInfo = [[linccer.userInfo mutableCopy] autorelease];
    if (userInfo == nil) {
        userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    }

    [userInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"clientName"] forKey:@"client_name"];

    linccer.userInfo = userInfo;
}


- (void)encryptionError: (NSNotification *)notification {
    
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encryption Error", nil)
                                                   message:NSLocalizedString(@"Could not decrypt data. Something went horribly wrong.", nil)
                                                  delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles: nil];
    [view show];
    [view release];
    
}

- (void)encryptionNotEnabled: (NSNotification *)notification {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enable encryption", nil) message:NSLocalizedString(@"You need to enable encryption to communicate with this sender", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
    [alertView release];
    
}

- (void)noPublicKey: (NSNotification *)notification {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Could not find public key", nil) forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"Encryption Error" code:700 userInfo:userInfo];
    [statusViewController setError:error];

    
}


#pragma mark -
#pragma mark Private Methods
- (NSDictionary *)dictionaryToSend: (ItemViewController *)item {
	NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys: 
							 [NSArray arrayWithObject:[item.content dataDesctiption]], @"data", nil];
	
	return content;
}

- (void)handleError: (NSError *)error {
    
    NSLog(@"ERROR %@ ",error);
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
	

    
	if (self.sendingItem) {
		self.sendingItem.viewOrigin = self.defaultOrigin;
        [desktopData addhoccerController:self.sendingItem];
        self.sendingItem = nil;
	} else {
        if ([desktopData count] > 0 && ![[error domain] isEqualToString:@"PubKeyError"]) {
            if ([desktopData count] == 1){
                ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
                
                [desktopData removeHoccerController:item];	
            }
            else {
                for (int i=0;i<[desktopData count];i++){
                    ItemViewController *item = [desktopData hoccerControllerDataAtIndex:i];
                    if (item.content == nil){
                        [desktopData removeHoccerController:item];
                    }
                }
            }
        }
	}
	
	[desktopView reloadData];	
}

- (void)showSuccess: (ItemViewController *)item {
    [historyData addContentToHistory:item];		
    
	if (self.sendingItem) {
        self.sendingItem = nil;
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

- (id <Cryptor>)currentCryptor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"encryption"]) {
        if (cipherNeeded && [defaults boolForKey:@"autoPassword"]){
            if (self.sendingItem.content.canBeCiphered){
                NSLog(@"Random Key");
                return [[[AESCryptor alloc] initWithRandomKey] autorelease];
            }
            else {
                NSLog(@"Stored Key");
                return [[[AESCryptor alloc] initWithKey:[defaults stringForKey:@"encryptionKey"]] autorelease];
            }
        }
        else {
            NSLog(@"Stored Key");
            return [[[AESCryptor alloc] initWithKey:[defaults stringForKey:@"encryptionKey"]] autorelease];

        }
    } else {
        return [[[NoCryptor alloc] init] autorelease];
    }
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
    
    [httpClient release];
	
	[super dealloc];
}

@end
