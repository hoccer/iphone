//
//  ReceivedContentView.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ReceivedContentViewController.h"
#import "NSObject+DelegateHelper.h"
#import "HoccerContent.h"
#import "HoccerImage.h"
#import "HoccerVideo.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ReceivedContentViewController () 
- (void)hideReceivedContentView;
- (void)setReady;
- (void)setWaiting;
@end



@implementation ReceivedContentViewController

@synthesize delegate;
@synthesize hoccerContent;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"PausePlayer" object:nil];
    
}

- (void)dealloc {
	[hoccerContent release];
	[HUD release];
	
    [super dealloc];
}


- (void)showActionSheet {
    if (hoccerContent.descriptionOfSaveButton != nil){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Hocc again",nil),hoccerContent.descriptionOfSaveButton, nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:super.view];
        [actionSheet release];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Hocc again",nil), nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:super.view];
        [actionSheet release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self resend:nil];
            break;
        case 1:
            if (hoccerContent.descriptionOfSaveButton != nil){
                [self save:nil];
            }
            break;
        default:
            break;
    }
}
- (IBAction)save: (id)sender	{
	[hoccerContent whenReadyCallTarget:self selector:@selector(setReady) context: nil];
	if ([hoccerContent needsWaiting]) {
		[self setWaiting];
	}
	
	if ([hoccerContent saveDataToContentStorage]) {
		return;
	}
	
	if (![hoccerContent.interactionController presentOpenInMenuFromRect:CGRectNull inView:self.view.superview animated:YES]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot handle content", nil) 
															message:NSLocalizedString(@"No installed program can handle this content type.", nil) 
														   delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
	}
}

- (IBAction)resend: (id)sender {
	hoccerContent.persist = YES;
	[delegate checkAndPerformSelector:@selector(receiveContentController:wantsToResendContent:) withObject:self withObject:hoccerContent];
}

- (void)setHoccerContent: (HoccerContent*) content {	
	if (hoccerContent != content) {
		[hoccerContent release];
		hoccerContent = [content retain];
	}
	
	[self.view insertSubview: content.fullscreenView atIndex:0];
	self.view.multipleTouchEnabled = YES;
	
	[self.view setNeedsDisplay];
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 367);
}
#pragma mark -
#pragma mark ReceivedContentView Delegate Methods

-  (void)hideReceivedContentView {
	[self setReady];
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextView class]]) {
			[view resignFirstResponder];
		}
	}
}

-  (void)setWaiting {
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Saving";
	
	[HUD show:YES];
}

- (void)setReady {
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
	HUD.labelText = @"Saved";
	[NSTimer scheduledTimerWithTimeInterval:1 target: self selector:@selector(hideHUD) userInfo:nil repeats:NO];
	
}

- (void)hideHUD {
	[HUD hide:YES];
}


@end
