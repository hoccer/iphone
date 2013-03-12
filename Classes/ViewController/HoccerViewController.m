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
#import "ChannelViewController.h"
#import "ConnectionStatusViewController.h"

#import "StatusBarStates.h"
#import "HoccerContentFactory.h"
#import "ErrorViewController.h"

#import "FileUploader.h"
#import "NSData_Base64Extensions.h"

#import "ImageSelectViewController.h"
#import "ContactSelectViewController.h"
#import "HocletSelectViewController.h"


#import <SystemConfiguration/SystemConfiguration.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaItemCollection-Utils.h"
#import <AVFoundation/AVFoundation.h>
#import "StartAnimationiPhoneViewController.h"


#import "DataManager.h"
#import "NSData+CommonCrypto.h"


@interface HoccerViewController ()
@property (retain, nonatomic) ItemViewController *sendingItem;

- (void)showNetworkError: (NSError *)error;
- (void)ensureViewIsHoccable;

- (void)clientNameChanged:(NSNotification *)notification;
- (void)clientChannelChanged:(NSNotification *)notification;
- (void)startChannelAutoReceiveMode:(NSNotification *)notification;
- (id <Cryptor>)currentCryptor;

@end

@implementation HoccerViewController

typedef enum {
    HOCCER_SENDING_SWIPE = 0,
    HOCCER_SENDING_THROW,
    HOCCER_RECEIVING_SWIPE,
    HOCCER_RECEIVING_THROW,
    HOCCER_AUTO_RECEIVING_THROW,
    HOCCER_LOADING_FROM_FILECACHE,
    HOCCER_IDLING
} HOCCER_STATUS;

@synthesize delegate; 
@synthesize settingViewController;
@synthesize channelViewController;
@synthesize gestureInterpreter;
@synthesize statusViewController;
@synthesize groupViewController;
@synthesize desktopData;
@synthesize defaultOrigin;
@synthesize hoccabilityLabel;
@synthesize hoccabilityInfo;
@synthesize linccer;
@synthesize sendingItem;
@synthesize errorViewController;
@synthesize autoReceiveMode;
@synthesize tabBar;
@synthesize pullDownActionInProgress;
@synthesize pullDownBackgroundImage;

+ (void) initialize
{
	NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	
    NSMutableDictionary *defauts = [NSMutableDictionary dictionaryWithContentsOfFile: filepath];
    [defauts setObject:[UIDevice currentDevice].name forKey:@"clientName"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defauts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	self.settingViewController = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    autoReceiveMode = NO;
    closeAutoReceive = NO;
    
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(fetchStatusUpdate) userInfo:nil repeats:NO];

	linccer = [[HCLinccer alloc] initWithApiKey:API_KEY secret:SECRET sandboxed: USES_SANDBOX];
	linccer.delegate = self;
    [self clientNameChanged:nil];
    [self clientChannelChanged:nil];
    
	desktopView.delegate = self;
	gestureInterpreter.delegate = self;

	desktopData = [[DesktopDataSource alloc] init];
	desktopData.viewController = self;
		
	desktopView.shouldSnapToCenterOnTouchUp = YES;
	desktopView.dataSource = desktopData;
	
	historyData = [[HistoryData alloc] init];
	self.defaultOrigin = CGPointMake(7, 55);

	transferController = [[TransferController alloc] init];
	transferController.delegate = self;
	
	statusViewController.delegate = self;
    errorViewController = [[ErrorViewController alloc] initWithNibName:@"ErrorViewController" bundle:[NSBundle mainBundle]];
    
    hoccerStatus = HOCCER_IDLING;
	failcounter = 0;
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(networkChanged:) 
												 name:@"NetworkConnectionChanged" 
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientNameChanged:)
                                                 name:@"clientNameChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelChanged:)
                                                 name:@"clientChannelChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startChannelAutoReceiveMode:)
                                                 name:@"startChannelAutoReceiveMode"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTextInputVC:) name:@"showTextInputVC" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPlayer) name:@"playPlayer" object:nil];

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
- (void)fetchStatusUpdate
{
	httpClient = [[HttpClient alloc] initWithURLString:@"http://api.hoccer.com"];
	httpClient.target = self;
	[httpClient getURI:@"/iphone/status2.json" success:@selector(httpConnection:didReceiveStatus:)];
}

#pragma mark -
#pragma mark httpconnection delegate
- (void)httpConnection:(HttpConnection *)connection didReceiveStatus: (NSData *)data
{
	linccer.latency = connection.roundTripTime;
	[linccer updateEnvironment];
	
	NSDictionary *message = nil;
	@try {
        
        if (USES_DEBUG_MESSAGES) { NSLog(@"  HttpConnection didReceiveStatus connection = #%@#", connection.request); }

		message = [data yajl_JSON];
	}
	@catch (NSException * e) {
        if (USES_DEBUG_MESSAGES) { NSLog(@"HoccerViewController httpConnection:connection didReceiveStatus : %@", e); }
        else { NSLog(@"%@", e); }
    }
    
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

- (void)httpConnection:(HttpConnection *)connection didReceiveData:(NSData *)data
{
    // nicht genutzt
    //NSLog(@"richtig");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
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
    UIActionSheet *contactChooser = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Button_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Choose Contact", nil), NSLocalizedString(@"My Contact", nil), nil];
    contactChooser.tag = 2;
    contactChooser.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [contactChooser showInView:self.view];
    [contactChooser release];
}

- (IBAction)selectContact:(id)sender {
    ContactSelectViewController *controller = [[ContactSelectViewController alloc] init];
    controller.delegate = self;
    [self presentContentSelectViewController:controller];
    [controller release];
}

- (IBAction)selectMyContact:(id)sender
{
    ABRecordID ownContact = [[NSUserDefaults standardUserDefaults] integerForKey:@"uservCardRef"];
    if (ownContact == 0) {
        UIAlertView *contactAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Please set contact", nil) message:NSLocalizedString(@"Please select your own contact.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Button_OK", nil), nil];
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
- (IBAction)selectImage: (id)sender
{
    ImageSelectViewController *controller = [[ImageSelectViewController alloc] init];
    controller.delegate = self;
    [self presentContentSelectViewController:controller];
	[controller release];
}

- (IBAction)selectText: (id)sender
{
	HoccerContent* content = [[[HoccerText alloc] init] autorelease];
	[self setContentPreview: content];
}

- (IBAction)selectCamera: (id)sender
{
    ImageSelectViewController *controller = [[ImageSelectViewController alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera];
    controller.delegate = self;
    [self presentContentSelectViewController:controller];
    
	[controller release];
}


- (IBAction)selectMedia: (id)sender {
    
    UIActionSheet *mediaChooser;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        mediaChooser = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Button_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles: NSLocalizedString(@"Choose Photo/Video", nil), NSLocalizedString(@"Take Photo/Video", nil), nil];
    }
    else {
        mediaChooser = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Button_Cancel", nil) destructiveButtonTitle:nil otherButtonTitles: NSLocalizedString(@"Choose Photo/Video", nil), nil];
    }
    mediaChooser.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    mediaChooser.tag = 1;
    [mediaChooser showInView:self.view];
    [mediaChooser release];
}

- (IBAction)selectMusic:(id)sender
{    
    UIAlertView *musicAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Converting songs can take several minutes, please be patient", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Button_Cancel", nil) otherButtonTitles:NSLocalizedString(@"Button_OK", nil), nil];
    musicAlert.tag = 2;
    [musicAlert show];
    [musicAlert release];
}

- (IBAction)selectHoclet: (id)sender
{
    HocletSelectViewController *controller = [[HocletSelectViewController alloc] initWithNibName:@"HocletSelectViewController" bundle:nil];
    controller.delegate = self;
    
    [self presentContentSelectViewController:controller];
    [controller release];
}

- (IBAction)selectPasteboard: (id)sender
{
    HoccerPasteboard* content = [[[HoccerPasteboard alloc] init] autorelease];
    if (content != nil){
        [self setContentPreview: [content returnPastedContent]];
    }
    else {
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Copy&Paste did not work. Please try again.", nil) forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"Pasteboard failed" code:666 userInfo:userInfo];
        [self handleError:error];

    }

}

- (IBAction)selectAutoReceive:(id)sender
{
    if (USES_DEBUG_MESSAGES) {  NSLog(@"HoccerViewController selectAutoReceive");}
    NSNotification *notification = [NSNotification notificationWithName:@"startChannelAutoReceiveMode" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)showHistory: (id)sender {}
- (IBAction)toggleSelectContent: (id)sender {}
- (IBAction)toggleHistory: (id)sender {}
- (IBAction)toggleChannel: (id)sender {}
- (IBAction)toggleSettings: (id)sender {}

- (void)showSMSPicker:(NSString *)phone
{
    //	The MFMessageComposeViewController class is only available in iPhone OS 4.0 or later.
    //	So, we must verify the existence of the above class and log an error message for devices
    //		running earlier versions of the iPhone OS. Set feedbackMsg if device doesn't support
    //		MFMessageComposeViewController API.
    
    if ((phone == nil) || (phone.length <= 0)) {
        return;
    }
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	
	if (messageClass != nil) {
		// Check whether the current device is configured for sending SMS messages
		if ([messageClass canSendText]) {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            
            //[picker setBody:@"Hallo, bitte oeffne diesen link. Ich möchte dir ein File schicken: hoccer://hallo"];
            NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];

            NSString *contentTemplate = NSLocalizedString(@"Message_FileSharingText", nil);
            NSString *channelLink = [@"hoccerchannel://channel/" stringByAppendingString:channel];
            NSString *content = [NSString stringWithFormat:contentTemplate, channelLink];
            [picker setBody:content];

            [picker setRecipients:[[NSArray alloc] initWithObjects:phone, nil]];
            
            [self presentModalViewController:picker animated:YES];
            [picker release];
		}
		else {
			NSLog(@"Device not configured to send SMS - 1.");
		}
	}
	else {
        NSLog(@"Device not configured to send SMS - 2.");
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
            //NSLog(@"Result: SMS sending canceled");
			break;
		case MessageComposeResultSent:
            //NSLog(@"Result: SMS sent");
			break;
		case MessageComposeResultFailed:
            //NSLog(@"Result: SMS sending failed");
			break;
		default:
            //NSLog(@"Result: SMS not sent");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)showDesktop {}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0: {
                    [self checkAndPerformSelector:@selector(selectImage:) withObject:self];
                    break;
                }
                case 1: {
                    [self checkAndPerformSelector:@selector(selectCamera:) withObject:self];
                    break;
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
                    UIAlertView *contactAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Please set contact", nil) message:NSLocalizedString(@"Please select your own contact.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Button_OK", nil), nil];
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
    mediaPicker.prompt = nil;
    
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

- (SettingViewController *)settingViewController {
	if (settingViewController == nil) {
		settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
	}
	
	return settingViewController;
}

- (ChannelViewController *)channelViewController {
	if (channelViewController == nil) {
		channelViewController = [[ChannelViewController alloc] initWithNibName:@"ChannelViewController" bundle:nil];
        channelViewController.delegate = self;
	}
	return channelViewController;
}

- (void)setContentPreview: (HoccerContent *)content
{
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
    
    
    // hier : #####
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPlayer) name:@"playPlayer" object:nil];
    
    //######
	
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

//###########
- (void)playPlayer
{
    //NSLog(@"hoccerviewcontroller playPlayer");
    
    ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
    if (item != nil) {
        //NSLog(@"  --- hoccerviewcontroller playPlayer");
        [item playPlayer];
    }
}

//##########

#pragma mark -
#pragma mark GesturesInterpreter Delegate Methods

- (void)gesturesInterpreterDidDetectCatch: (GesturesInterpreter *)aGestureInterpreter
{
	if (![hoccingRules hoccerViewControllerMayCatch:self]) {
		return;
	}

	[groupViewController hideViewAnimated:YES];

	[FeedbackProvider playCatchFeedback];
	ItemViewController *item = [[[ItemViewController alloc] init] autorelease];
	item.delegate = self;
	item.viewOrigin = CGPointMake(desktopView.frame.size.width / 2 - item.contentView.frame.size.width / 2, 90);
	
	[desktopData addhoccerController:item];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.fromValue = [NSValue valueWithCGPoint: CGPointMake(desktopView.frame.size.width / 2, 0)];
	animation.duration = 0.2;
	
	[desktopView insertView:item.contentView atPoint:item.viewOrigin withAnimation:animation];

	[self willStartDownload:item];
	[linccer receiveWithMode:HCTransferModeOneToMany];
	
	[statusViewController setState:[ConnectionState state]];
	[statusViewController setUpdate:NSLocalizedString(@"Connecting..", nil)];
    
    hoccerStatus = HOCCER_RECEIVING_THROW;
    
    self.sendingItem = nil;
}

- (void)gesturesInterpreterDidDetectThrow: (GesturesInterpreter *)aGestureInterpreter
{
	if (![hoccingRules hoccerViewControllerMayThrow:self]) {
		return;
	}
    
    if (encryptionEnabled && !clientSelected && [[NSUserDefaults standardUserDefaults] boolForKey:@"sendPassword"]){
        
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Nobody selected. Please select one or more users for secure HOCCER transfer.n", nil) forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"Encryption Error" code:700 userInfo:userInfo];
        [errorViewController showError:error forSeconds:10];
        return;
        
    }
	
	[groupViewController hideViewAnimated:NO];
	
	[FeedbackProvider playThrowFeedback];
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
    self.sendingItem = item;
    item.content.cryptor = [self currentCryptor];
   	[linccer send:[self dictionaryToSend:item] withMode:HCTransferModeOneToMany];
	
	[statusViewController setState:[SendingState state]];
		[statusViewController setUpdateSending:NSLocalizedString(@"Connecting..", nil)];
    
	UIView *view = [desktopData viewAtIndex:0];
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.duration = 0.2;
	animation.toValue = [NSValue valueWithCGPoint: CGPointMake(view.center.x, -200)];
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	
	[desktopView animateView:[desktopData viewAtIndex:0] withAnimation:animation];
    
    hoccerStatus = HOCCER_SENDING_THROW;
    
    [self showInfoHudForMode:HCTransferModeOneToMany];

    [desktopData removeHoccerController:item];
}

- (void)switchAutoReceiveMode:(BOOL)on
{
    if (on) {
        if (USES_DEBUG_MESSAGES) { NSLog(@"#### SwitchAutoReceiveMode  ON ####"); }
                
        [groupViewController hideViewAnimated:NO];
        
        //[FeedbackProvider playCatchFeedback];
        ItemViewController *item = [[[ItemViewController alloc] init] autorelease];
        item.delegate = self;
        item.viewOrigin = CGPointMake(desktopView.frame.size.width / 2 - item.contentView.frame.size.width / 2, -500); // add outside view
        
        [desktopData addhoccerController:item];
        
        [desktopView insertView:item.contentView atPoint:item.viewOrigin withAnimation:nil];
        
        [self willStartDownload:item];
        
        [linccer pollWithMode:HCTransferModeOneToMany];
                
        hoccerStatus = HOCCER_AUTO_RECEIVING_THROW;
        self.autoReceiveMode = YES;
        self.sendingItem = nil;
    }
    else {
        if (USES_DEBUG_MESSAGES) { NSLog(@"SwitchAutoReceiveMode  OFF ----"); }
        
        if ([transferController hasTransfers]) {
            [transferController cancelTransfers];
        }
        [self removeAllItemsFromDesktop];

        ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
        if (item != nil) {
            [desktopData removeHoccerController:item];
        }

        [linccer cancelAllRequestsKeepPeek];
        
        hoccerStatus = HOCCER_IDLING;
        self.autoReceiveMode = NO;

        [desktopView reloadData];
    }
}

- (void)removeAllItemsFromDesktop
{
    if ([desktopData count] == 1) {
        ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
        if (item) {
            [desktopData removeHoccerController:item];
        }
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

#pragma mark -
#pragma mark DesktopViewDelegate

- (void)desktopView:(DesktopView *)desktopView didRemoveViewAtIndex:(NSInteger)index
{
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:index];
	if ([transferController hasTransfers]) {
		[transferController cancelTransfers];
	}
    else {
		[desktopData removeHoccerController:item];
	}
}


- (void)desktopView: (DesktopView *)desktopView didSweepInView: (UIView *)view
{
	if ([self.linccer isLinccing]) {
		return;
	}
	
	[FeedbackProvider playSweepIn];
	[groupViewController hideViewAnimated:YES];
	
	[statusViewController setState:[ConnectionState state]];
	[statusViewController setUpdate:NSLocalizedString(@"Connecting..", nil)];
	
	ItemViewController *item = [desktopData hoccerControllerDataForView: view];
	
	[self willStartDownload:item];
	
	[linccer receiveWithMode:HCTransferModeOneToOne];
    
    hoccerStatus = HOCCER_RECEIVING_SWIPE;
    
    self.sendingItem = nil;
}

- (void)desktopView:(DesktopView *)desktopView didSweepOutView:(UIView *)view
{
	if ([linccer isLinccing]) {
		return;
	}
    
    if (encryptionEnabled && !clientSelected && [[NSUserDefaults standardUserDefaults] boolForKey:@"sendPassword"]){

        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Nobody selected. Please select one or more users for secure HOCCER transfer.", nil) forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"Encryption Error" code:700 userInfo:userInfo];
        [errorViewController showError:error forSeconds:10];
        [self->desktopView reloadData];
        return;
    }
    
	[FeedbackProvider playSweepOut];
	
	[groupViewController hideViewAnimated:YES];
	[statusViewController setState:[SendingState state]];
	[statusViewController setUpdateSending:NSLocalizedString(@"Connecting..", nil)];
    
	ItemViewController *item = [desktopData hoccerControllerDataForView: view];
    self.sendingItem = item;
    item.content.cryptor = [self currentCryptor];
	item.isUpload = YES;
    
    hoccerStatus = HOCCER_SENDING_SWIPE;
    
    [self showInfoHudForMode:HCTransferModeOneToOne];
    
//
//  plaetzchens black magic: DO NOT REMOVE !!!11!1!
//
    if ([item.content isKindOfClass:[HoccerText class]]) {
        HoccerText *text = (HoccerText *)item.content;
        if ([text.content isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"HCCodeName"]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"HCVideoLink"]]];
        }
    }
		
	[linccer send:[self dictionaryToSend: item] withMode:HCTransferModeOneToOne];	
    
    [desktopData removeHoccerController:self.sendingItem];
}

- (BOOL)desktopView:(DesktopView *)aDesktopView needsEmptyViewAtPoint:(CGPoint)point
{
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

- (void)updateChannelButton
{
    // by default and on iPad Group Button and Channel Button are the same
    [self updateGroupButton];
}

- (void)updateGroupButton
{
    // should be overloaded and never be called
    NSLog(@"HoccerViewController updateGroupButton should be overiden and never be called");
}

#pragma mark -
#pragma mark PullDownViewDelegate


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
    
	CGPoint prevLocation = [touch previousLocationInView:self.pullDownView];
    //	CGPoint currentLocation = [touch locationInView:self.pullDownView];
    
    CGRect myRect = self.pullDownView.frame;
    
    //    NSLog(@" touchesBegan: pullDownView top %f , bottom %f", myRect.origin.y, myRect.origin.y + myRect.size.height);
    //    NSLog(@" touchesBegan: pullDownView prevLocation %f %f", prevLocation.x, prevLocation.y);
    //    NSLog(@" touchesBegan: pullDownView currentLocation %f %f", currentLocation.x, currentLocation.y);
    
    // return if not on pulldown view
    if (prevLocation.y < 0 || (prevLocation.y > myRect.size.height + 50)) {
        // NSLog(@" touchesBegan: not in pulldown handle");
        self.pullDownActionInProgress = NO;
    } else {
        // NSLog(@" touchesBegan: in pulldown handle");
        self.pullDownActionInProgress = YES;
        self.pullDownDragged = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.pullDownActionInProgress == NO) {
        return;
    }
    
	UITouch* touch = [touches anyObject];
    
	CGPoint prevLocation = [touch previousLocationInView:self.pullDownView];
	CGPoint currentLocation = [touch locationInView:self.pullDownView];
    
    CGRect myRect = self.pullDownView.frame;
    
    //    NSLog(@" touchesMoved: pullDownView top %f , bottom %f", myRect.origin.y, myRect.origin.y + myRect.size.height);
    //    NSLog(@" touchesMoved: pullDownView prevLocation %f %f", prevLocation.x, prevLocation.y);
    //    NSLog(@" touchesMoved: pullDownView currentLocation %f %f", currentLocation.x, currentLocation.y);
    
    float minPosition = -67;
    float maxPosition = 0;
    
    // calc the move:
    float movePoints = currentLocation.y - prevLocation.y;
    
    // move to position
    myRect.origin.y += movePoints;
    if (myRect.origin.y > maxPosition) {
        myRect.origin.y = maxPosition;
    } else if (myRect.origin.y < minPosition) {
        myRect.origin.y = minPosition;
    }
    self.pullDownView.frame = myRect;
    
    self.pullDownDragged = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.pullDownActionInProgress == NO) {
        return;
    }
	
    //    UITouch* touch = [touches anyObject];
    
    //	CGPoint prevLocation = [touch previousLocationInView:self.pullDownView];
    //	CGPoint currentLocation = [touch locationInView:self.pullDownView];
    
    CGRect myRect = self.pullDownView.frame;
    
    //    NSLog(@" touchesEnded: pullDownView top %f , bottom %f", myRect.origin.y, myRect.origin.y + myRect.size.height);
    //    NSLog(@" touchesEnded: pullDownView prevLocation %f %f", prevLocation.x, prevLocation.y);
    //    NSLog(@" touchesEnded: pullDownView currentLocation %f %f", currentLocation.x, currentLocation.y);
    
    float minPosition = -67;
    float maxPosition = 0;
    float swapPosition = (maxPosition + minPosition)/2;
    
    enum Target {
        NO_POSITION,
        GOTO_MIN_POSITION,
        GOTO_MAX_POSITION
    };
    
    enum Target gotoPosition = NO_POSITION;
    
    if (self.pullDownDragged == NO) {
        // Set Up Toggle mode
        if (myRect.origin.y > swapPosition) {
            gotoPosition = GOTO_MIN_POSITION;
        } else {
            gotoPosition = GOTO_MAX_POSITION;
            
        }
    }
    
    if ((myRect.origin.y > swapPosition && gotoPosition == NO_POSITION) || gotoPosition == GOTO_MAX_POSITION) {
        [self movePullDownToMaxDownPosition];
        if (self.autoReceiveMode) {
            // NSLog(@"not again switch to on ......................");
        }
        else {
            [self selectAutoReceive:self];
            // NSLog(@"touchesEnded startAnimating");
            [self.activityIndi startAnimating];
        }
    }
    else {
        [self movePullDownToNormalPosition];
        if (self.autoReceiveMode) {
            // NSLog(@"touchesEnded stopAnimating");
            [self.activityIndi stopAnimating];
            [self switchAutoReceiveMode:NO];
        }
        else {
            // NSLog(@"not again switch to OFF......................");
        }
    }
}
- (void)movePullDownToHidePosition
{
    CGRect pullDownViewRect = self.pullDownView.frame;
    pullDownViewRect.origin.y = - 100.0;
    pullDownViewRect.size.height = 0;
    
    self.pullDownView.frame = pullDownViewRect;
    
    // NSLog(@"movePullDownToHidePosition - pullDownView.size.height = %f", self.pullDownView.frame.size.height);
    
    self.pullDownView.hidden = YES;
}

- (void)movePullDownToNormalPosition
{
    self.pullDownView.hidden = NO;
    
    // NSLog(@"movePullDownToNormalPosition");
    
    CGRect pullDownViewRect = self.pullDownView.frame;
    pullDownViewRect.origin.y = -67.0;
    pullDownViewRect.size.height = 100;
    self.pullDownView.frame = pullDownViewRect;
    
}

- (void)movePullDownToMaxDownPosition
{
    CGRect pullDownViewRect = self.pullDownView.frame;
	pullDownViewRect.origin.y = 0.0;
    pullDownViewRect.size.height = 100;
	self.pullDownView.frame = pullDownViewRect;
}

- (void)ensurePullDownPosition {
    if (self.autoReceiveMode) {
        [self movePullDownToMaxDownPosition];
    } else {
        [self movePullDownToNormalPosition];
    }
}

#pragma mark -
#pragma mark Connection Status View Controller Delegates
- (void) connectionStatusViewControllerDidCancel:(ConnectionStatusViewController *)controller
{
	connectionEstablished = NO;

    BOOL isChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];
    if (isChannelMode) {
        if (USES_DEBUG_MESSAGES) { NSLog(@"HoccerViewController connectionStatusViewControllerDidCancel ---- isChannelMode"); }
    }
    else {
        if (USES_DEBUG_MESSAGES) { NSLog(@"HoccerViewController connectionStatusViewControllerDidCancel ## NO isChannelMode"); }
    }

    if (![linccer isLinccing] && ![transferController hasTransfers]) {
        return;
    }
    
	[linccer cancelAllRequestsKeepPeek];
    if (![infoHud isHidden])
        [infoHud hide:YES];
	
    if (self.sendingItem) {
		self.sendingItem.viewOrigin = self.defaultOrigin;
        [desktopData addhoccerController:self.sendingItem];
        [desktopView reloadData];
        
        self.sendingItem = nil;
	} else {
        if ([desktopData count] == 1){
            ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
            if (item) {
                [desktopData removeHoccerController:item];
            }
            [transferController cancelTransfers];
        }
        else {
            for (int i=0;i<[desktopData count];i++){
                ItemViewController *item = [desktopData hoccerControllerDataAtIndex:i];
                if (item.content == nil){
                    [desktopData removeHoccerController:item];
                    [transferController cancelTransfers];
                }
            }
        }
	}
    
	[desktopView reloadData];
}

- (void)toggleAutoReceiveMode
{
    if (autoReceiveMode) {
        autoReceiveMode = NO;
    }
    else {
        autoReceiveMode = YES;
    }
}

#pragma mark -
#pragma mark Channel Contact Picker

- (void)showChannelContactPicker
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    
    [self presentModalViewController:peoplePicker animated:YES];
}

#pragma mark -
#pragma mark ABPeoplePickerNavigationController Delegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    //dismiss
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    //dismiss
    [self dismissModalViewControllerAnimated:NO];

    NSString* name = (NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        //NSLog(@"number of phoneNumbers = %ld", ABMultiValueGetCount(phoneNumbers));
        phone = (NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        //for (int i=0; i > ABMultiValueGetCount(phoneNumbers); i++) {
            //NSString *phoneTmp = (NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            //NSLog(@"Multi Phone %d = %@", i, phoneTmp);
        //}
    }
    else {
        phone = @"[None]";
    }
    //NSLog(@"name = %@", name);
    //NSLog(@"phone = %@", phone);
    
    DataManager *dm = [DataManager sharedDataManager];
    NSString *channelNameToUse = [dm generateRandomString:12];
    NSLog(@"randomChannelString  =  %@", channelNameToUse);
    
    //NSString *channelNameToUse = @"";
    if ((name != nil) && (name.length > 0)) {
//        const char *cKey  = [@"18aXprM!" cStringUsingEncoding:NSASCIIStringEncoding];
//        //const char *cData = [name cStringUsingEncoding:NSASCIIStringEncoding];
//        const char *cData = [randomChannelString cStringUsingEncoding:NSASCIIStringEncoding];
//        unsigned char cHMAC[9];
//        CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
//        NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
//        channelNameToUse = [HMAC asBase64EncodedString];
    }
    else {
//        channelNameToUse = @"3xF4rY2lKj";
    }
//    NSLog(@"channelNameToUse     =  %@", channelNameToUse);
    
    //[[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"channel"];
    
    NSString *oldchannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
    if (![oldchannel isEqualToString:channelNameToUse]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:channelNameToUse forKey:@"channel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //NSNotification *notification = [NSNotification notificationWithName:@"clientChannelChanged" object:self];
        //[[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    //phone = @"00491777177737";
    
    if (phone) {
        // 0049 zu anfang checken
    }
    
    //DataManager *dm = [DataManager sharedDataManager];
    
    //[dm sendKSMS:@"hallo" toPhone:phone toName:name from:@"BauTicker"];
    
    [self showSMSPicker:phone];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

#pragma mark -
#pragma mark ItemViewController 

- (void)willStartDownload: (ItemViewController *)item {
	item.isUpload = NO;
}

- (void)itemViewControllerWasClosed:(ItemViewController *)item
{
    if (USES_DEBUG_MESSAGES) { NSLog(@"itemViewControllerWasClosed:"); }
	[transferController cancelTransfers];
	
	[desktopData removeHoccerController:item];
	[desktopView reloadData];
}

- (void)itemViewControllerSaveButtonWasClicked: (ItemViewController *)item
{
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
														   delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_OK", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
    [item.contentView hideSpinner];
}

- (void)finishedSaving: (ItemViewController *)item {
	[item.contentView hideSpinner];
	[item.contentView showSuccess];
}

#pragma mark -
#pragma mark TransferController Delegate

- (void)transferController:(TransferController *)controller didFinishTransfer:(id)object
{
    failcounter = 0;
    [self ensureViewIsHoccable];

	if ([desktopData count] == 0) {
		return;
	}
    //NSLog(@"HoccerViewController transferController: didFinishTransfer:");
    
	ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
	
	if (!item.isUpload) {
        [item updateView];
	}
    
    BOOL isChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];
    if (isChannelMode) {
        //[self ];
        if (USES_DEBUG_MESSAGES) { NSLog(@"HoccerViewController transferController:(TransferController *)controller didFinishTransfer"); }
    }
}

- (void)transferControllerDidFinishAllTransfers:(TransferController *)controller
{
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

- (void) transferController:(TransferController *)controller didUpdateTotalProgress:(TransferProgress *)progress
{
    // NSLog(@"HoccerViewController transferController: didUpdateTotalProgress %@", progress);
	if (connectionEstablished) {
		[statusViewController setProgressUpdate: [progress percentDone]];
	}
}

- (void) transferController:(TransferController *)controller didFailWithError:(NSError *)error forTransfer:(id)object
{
//    if (failcounter < 3){
//        [self retryLastAction];
//        failcounter++;
//    }
//    else {
        [self handleError: error];
        [self hideHUD];
        cipherNeeded = YES;
        failcounter = 0;
//    }
}

- (void) transferController:(TransferController *)controller didPrepareContent: (id)object {
	[self hideHUD];
    
    if ([object isKindOfClass:[HoccerMusic class]]){
        HoccerMusic *tempMusic = (HoccerMusic *)object;
        if (tempMusic.thumb && tempMusic.data ==nil){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"The loading of the song failed. Please make sure that the song is NOT copyright protected (DRM).", nil) forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"Song failed" code:796 userInfo:userInfo];
            [self handleError:error];
        }
    }
    cipherNeeded = NO;
}

#pragma mark -
#pragma mark HCLinccerDelegate Methods

- (void)linccer:(HCLinccer *)linccer didUpdateEnvironment:(NSDictionary *)quality
{
    if(![hud.labelText isEqualToString:NSLocalizedString(@"Preparing Content...",nil)]){
        [self hideHUD];
    }

	[self ensureViewIsHoccable];
}

- (void)linccer:(HCLinccer *)aLinccer didFailWithError:(NSError *)error
{
    if (self.autoReceiveMode) {
        if (error.code == 504) {
            // retry
            NSLog(@" ### found error code  504 and repoll waiting = true  : %d", error.code);
            
            [aLinccer pollWithMode:HCTransferModeOneToMany];
            
            return;
        }
    }
    
    if (failcounter < 3 && error.code != 409){
        [self retryLastAction];
        failcounter ++;
    }
    else {
        connectionEstablished = NO;
        [self handleError:error];
        failcounter = 0;
    }
}

- (void)willFinishAutoReceive
{
    //close pullDown
    // NSLog(@"willFinishAutoReceive stopAnimating");
    [self.activityIndi stopAnimating];
    
    [self movePullDownToNormalPosition];
    
    self.autoReceiveMode = NO;
}

- (void)linccer:(HCLinccer *)linncer didReceiveData:(NSArray *)data
{
    if (USES_DEBUG_MESSAGES) { NSLog(@"  1 linccer:   didReceiveData:"); }

    failcounter = 0;
	[self ensureViewIsHoccable];
	
	connectionEstablished = YES;

	NSDictionary *firstPayload = [data objectAtIndex:0];
	NSArray *content = [firstPayload objectForKey:@"data"];
	
    if ([desktopData count] > 0) {
        
        closeAutoReceive = YES;
        
        HoccerContent *hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromDict:[content objectAtIndex:0]];
        ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
        item.content = hoccerContent;
        item.content.persist = YES;
        currentContent = hoccerContent;

        if ([hoccerContent transferer]) {
            for (id transferer in [hoccerContent transferers]) {
                hoccerStatus = HOCCER_LOADING_FROM_FILECACHE;
                [transferController addContentToTransferQueue:transferer];		
            }
        }
        else {
            [self showSuccess:item];
            
        }
        CGPoint myOrigin = CGPointMake(desktopView.frame.size.width / 2 - item.contentView.frame.size.width / 2,
                                       desktopView.frame.size.height / 2 - item.contentView.frame.size.height / 2);
        
        // NSLog(@"myOrigin = %f %f", myOrigin.x, myOrigin.y);
        item.viewOrigin = myOrigin;
        [desktopView reloadData];

        if (USES_DEBUG_MESSAGES) { NSLog(@"  2 linccer:   didReceiveData:"); }
    }
    if (closeAutoReceive) {
        [self willFinishAutoReceive];
    }
    
    BOOL isChannelMode = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate channelMode];
    if (isChannelMode) {
        if (USES_DEBUG_MESSAGES) { NSLog(@"HoccerViewController linccer:(HCLinccer *)linncer didReceiveData ---- isChannelMode"); }
        
        [self updateChannelButton];
    }
}

- (void) linccer:(HCLinccer *)linccer didSendData:(NSArray *)info
{
    if (USES_DEBUG_MESSAGES) { NSLog(@"linccer:   didSendData:"); }

    failcounter = 0;
	[self ensureViewIsHoccable];
	connectionEstablished = YES;

    if (self.sendingItem && fileUploaded) {
        [self showSuccess:self.sendingItem];
    }
}

- (void) linccer:(HCLinccer *)linccer keyHasChangedForClientName:(NSString *)client
{
    UIAlertView *keyAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Title_PublicKeyChanged", nil)
                                                       message:[NSString stringWithFormat:NSLocalizedString(@"Message_PublicKeyChanged", nil), client]
                                                      delegate:nil
                                             cancelButtonTitle:@"Button_OK"
                                             otherButtonTitles:nil, nil];
    [keyAlert show];
    [keyAlert release];
}

#pragma mark -
#pragma mark LongTouch Detector

-(void)desktopLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if([hoccingRules hoccerViewControllerMayAddAnotherView:self]){
            CGPoint location = [gestureRecognizer locationInView:desktopView ];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *pasteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Button_Paste", nil) action:@selector(selectPasteboard:)];
            //before autoReceive [menuController setMenuItems:[NSArray arrayWithObject:pasteMenuItem]];

            //UIMenuItem *autoReceiveMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"AutoReceive", nil) action:@selector(selectAutoReceive:)];
            [menuController setMenuItems:[NSArray arrayWithObjects:pasteMenuItem, nil]];
            
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

- (void)clientNameChanged: (NSNotification *)notification
{
    NSMutableDictionary *userInfo = [[linccer.userInfo mutableCopy] autorelease];
    if (userInfo == nil) {
        userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    [userInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"clientName"] forKey:@"client_name"];
    
    linccer.userInfo = userInfo;
}

- (void)clientChannelChanged:(NSNotification *)notification
{
//    NSLog(@"HoccerViewController - clientChannelChanged - notification: %@", notification);
}

- (void)startChannelAutoReceiveMode:(NSNotification *)notification
{
//    NSLog(@"HoccerViewController - startChannelAutoReceiveMode - notification: %@", notification);

    [self switchAutoReceiveMode:YES];
    
}

- (void)encryptionError: (NSNotification *)notification
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Encryption Error", nil)
                                                   message:NSLocalizedString(@"Could not decrypt data. Something went horribly wrong.", nil)
                                                  delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Cancel", nil) otherButtonTitles: nil];
    [view show];
    [view release];
    
}

- (void)encryptionNotEnabled: (NSNotification *)notification
{    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enable encryption", nil) message:NSLocalizedString(@"You need to enable encryption to communicate with this sender", nil) delegate:nil cancelButtonTitle:@"Button_OK" otherButtonTitles:nil, nil];
    
    [alertView show];
    [alertView release];
    
}

- (void)noPublicKey: (NSNotification *)notification
{    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Could not find public key", nil) forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"Encryption Error" code:700 userInfo:userInfo];
    [self handleError:error];

    
}


#pragma mark -
#pragma mark Private Methods
- (NSDictionary *)dictionaryToSend: (ItemViewController *)item {
    if (item) {
        if (item.content) {
            if ([item.content dataDesctiption]) {
                NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSArray arrayWithObject:[item.content dataDesctiption]], @"data", nil];
                
                return content;
            }
        }
    }
    return nil;
}

- (void)handleError: (NSError *)error {
    
	if (error == nil) {
		[statusViewController hideStatus];
		return;
	}
   
   	if (infoHud && [infoHud isKindOfClass:[MBProgressHUD class]]) {
        
        if (!infoHud.isHidden){
            [infoHud hide:YES];
        }
    }

	if ([[error domain] isEqual:NSURLErrorDomain]) {
		[statusViewController hideStatus];
		[self showNetworkError:error];
	} else if ([[error domain] isEqual:@"HttpErrorDomain"] && 
					[[[error userInfo] objectForKey:@"HttpClientErrorURL"] rangeOfString:@"environment"].location != NSNotFound) {
		[statusViewController hideStatus];
		[self showNetworkError:error];	
	} 
    else {
        [statusViewController hideStatus];
		[errorViewController showError:error forSeconds:10];
	}
    
	if (self.sendingItem) {
		self.sendingItem.viewOrigin = self.defaultOrigin;
        [desktopData addhoccerController:self.sendingItem];
        self.sendingItem = nil;
	} else {
        if ([desktopData count] > 0 && ![[error domain] isEqualToString:@"PubKeyError"]) {
            if ([desktopData count] == 1){
                ItemViewController *item = [desktopData hoccerControllerDataAtIndex:0];
                if (item) {
                    [desktopData removeHoccerController:item];
                }
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

- (void)showSuccess:(ItemViewController *)item {
    [historyData addContentToHistory:item];		
    
	if (self.sendingItem) {
        self.sendingItem = nil;
		[desktopView reloadData];
	} else {
		[item updateView];
	}
    [statusViewController setState:[SuccessState state]];
    [statusViewController showMessage: NSLocalizedString(@"Success", nil) forSeconds:5];

    if (hoccerStatus <= 1) {
        if (infoHud || [infoHud isKindOfClass:[MBProgressHUD class]]){
            if (!infoHud.isHidden){
                @try {
                    [infoHud hide:YES];

                }
                @catch (NSException *exception) {
                    //NSLog(@"Error: %@",exception);
                }
            }
        }
    }
	connectionEstablished = NO;
}

- (void)showNetworkError: (NSError *)error {	
	desktopView.userInteractionEnabled = NO;
	linccer.environmentUpdateInterval = 5;
	
	if (errorView == nil) {
        [self showTabBar:NO];
        
		NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ErrorView" owner:self options:nil];
		errorView = [[views objectAtIndex:0] retain];
        
        [errorView setFrame:desktopView.frame];
		[desktopView insertSubview:errorView atIndex:0];
        
        CGRect errorRect = errorView.frame;
        errorView.frame = errorRect;
        
	}
	
	BOOL reachable = [(HoccerAppDelegate *)[UIApplication sharedApplication].delegate networkReachable];
	if ([[error domain] isEqual:NSURLErrorDomain] && !reachable) {
		((UILabel *)[errorView viewWithTag:2]).text = NSLocalizedString(@"No Internet connection. Please check your network settings and try to connect to the internet.", nil);
	} else {
		((UILabel *)[errorView viewWithTag:2]).text = NSLocalizedString(@"The HOCCER service can not be reached. Please check your network connection or try again later.", nil);
	}
    [self sizeLabel:((UILabel *)[errorView viewWithTag:1]) toRect:((UILabel *)[errorView viewWithTag:1]).frame];
	[self sizeLabel:((UILabel *)[errorView viewWithTag:2]) toRect:((UILabel *)[errorView viewWithTag:2]).frame];
    
	[self hideHUD];
}

- (void)ensureViewIsHoccable
{
	desktopView.userInteractionEnabled = YES;
	linccer.environmentUpdateInterval = 25;

	if (errorView != nil) {
		[errorView removeFromSuperview];
		[errorView release]; 
		errorView = nil;
	}
    [self showTabBar:YES];
}

- (void)showTabBar:(BOOL)visible
{
    if (visible) {
        tabBar.userInteractionEnabled = YES;
        [self.view bringSubviewToFront:tabBar];
        tabBar.hidden = NO;
        tabBar.alpha = 1;
        tabBar.opaque = YES;
        navigationController.navigationBar.alpha = 1;
        navigationController.view.alpha = 1;
    } else {
        tabBar.userInteractionEnabled = NO;
        [self.view sendSubviewToBack:tabBar];
        //tabBar.hidden = YES;
        tabBar.opaque = NO;
        tabBar.alpha = 0.3;
        navigationController.navigationBar.alpha = 0.3;
    }
}

- (void)showHud {
	[self showHudWithMessage:NSLocalizedString(@"Preparing...", nil)];
}

- (void)showHudWithMessage: (NSString *)message {
	if (hud != nil) {
        [hud release];
	}
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
	
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = message;
    // NSLog(@"showHUD: message = %@", message);
    // self.view layoutIfNeeded];
	[hud show:YES];
    // [self.view layoutIfNeeded];
}


- (void)showInfoHudForMode:(NSString *)mode
{		
    infoHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [infoHud setAllowsCancelation:YES];
    [infoHud setDelegate:self];
	
    if ([mode isEqual: HCTransferModeOneToOne]){
        infoHud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_info_swipe-in"]] autorelease];
        infoHud.mode = MBProgressHUDModeCustomView;
        infoHud.labelText = @"Swipe on the\nother phone!";
        [infoHud show:YES];
    }
    else if ([mode isEqual: HCTransferModeOneToMany]){
        infoHud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_info_catch"]] autorelease];
        infoHud.mode = MBProgressHUDModeCustomView;
        infoHud.labelText = @"Catch with the other phones!";
        [infoHud show:YES];
    }


    }

- (void)hudDidCancel {
    [statusViewController cancelAction:nil];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
}

- (void)hideHUD {
	[hud hide:YES];
}

- (id <Cryptor>)currentCryptor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"encryption"]) {
        if (cipherNeeded && [defaults boolForKey:@"autoPassword"]){
            if (self.sendingItem.content.canBeCiphered){
                //NSLog(@"Random Key");
                return [[[AESCryptor alloc] initWithRandomKey] autorelease];
            }
            else {
                //NSLog(@"Stored Key");
                return [[[AESCryptor alloc] initWithKey:[defaults stringForKey:@"encryptionKey"]] autorelease];
            }
        }
        else {
            //NSLog(@"Stored Key");
            return [[[AESCryptor alloc] initWithKey:[defaults stringForKey:@"encryptionKey"]] autorelease];

        }
    } else {
        return [[[NoCryptor alloc] init] autorelease];
    }
}

- (void) sizeLabel: (UILabel *) label toRect: (CGRect) labelRect  {
    
    label.frame = labelRect;
    
    int fontSize = 300;
    int minFontSize = 5;
    
    CGSize constraintSize = CGSizeMake(label.frame.size.width, MAXFLOAT);
    
    do {
        label.font = [UIFont boldSystemFontOfSize:fontSize];
        
        CGSize labelSize = [[label text] sizeWithFont:label.font
                                    constrainedToSize:constraintSize
                                        lineBreakMode:UILineBreakModeWordWrap];
        
        if( labelSize.height <= label.frame.size.height )
            break;
        
        fontSize -= 2;
        
    } while (fontSize > minFontSize);
}

- (void) retryLastAction {
    switch (hoccerStatus) {
        case HOCCER_SENDING_SWIPE:
            if (self.sendingItem){
                [linccer send:[self dictionaryToSend: self.sendingItem] withMode:HCTransferModeOneToOne];
            }
            break;
        case HOCCER_RECEIVING_SWIPE:
                [linccer receiveWithMode:HCTransferModeOneToOne];
            break;
            
        case HOCCER_SENDING_THROW:
            if (self.sendingItem){
                [linccer send:[self dictionaryToSend: self.sendingItem] withMode:HCTransferModeOneToMany];
            }
            break;
        case HOCCER_RECEIVING_THROW:
            [linccer receiveWithMode:HCTransferModeOneToMany];
            break;
            
        case HOCCER_LOADING_FROM_FILECACHE: {
                for (id transferer in [currentContent transferers]) {
                    hoccerStatus = HOCCER_LOADING_FROM_FILECACHE;
                    [transferController addContentToTransferQueue: transferer];		
                }
            }
            break;
        default:
            break;
    }
}

- (void)showTextInputVC:(NSNotification *)notification {
    if (USES_DEBUG_MESSAGES) { NSLog(@"showTextInputVC:(NSNotification *)notification"); }
}

- (void)cancelPopOver {}

- (void)dealloc {
	[hoccabilityInfo release];
	[desktopView release];	
	[desktopData release];
	[gestureInterpreter release];
	[settingViewController release];
	[statusViewController release];
	[hoccingRules release];
	[transferController release];
	[hud release];
    [groupViewController release];
    
    [httpClient release];
    [_pullDownView release];
    // [_pullDownAnimationImage release];
    [_activityIndi release];
    
	[super dealloc];
}

@end
