
//
//  HelpController.m
//  Hoccer
//
//  Created by Robert Palmer on 04.02.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HelpController.h"
#import "HelpScrollView.h"


@implementation HelpController

- (id)initWithController: (UINavigationController *)viewController {
	self = [super init];
	if (self != nil) {
		controller = [viewController retain];
	}
	
	return self;
}
	
- (void)viewDidLoad {
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"firstRunTipShown"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"encryptionTipShown"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"talkPromotionShown"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"talkPromotionShown"]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PromoTitle_HoccerTalk", nil)
                                                        message:NSLocalizedString(@"PromoMessage_HoccerTalk", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Button_Continue",nil)
                                              otherButtonTitles:NSLocalizedString(@"Button_GotoAppstore",nil)
                                              ,nil];
        [alert show];
        [alert release];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"talkPromotionShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstRunTipShown"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"encryptionTipShown"]){
//		return;
//	}
//    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"encryptionTipShown"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"firstRunTipShown"] ){
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TipTitle_EncryptionAdded", nil)
//                                                        message:NSLocalizedString(@"TipMessage_EncryptionAdded", nil)
//                                                       delegate:self 
//                                              cancelButtonTitle:NSLocalizedString(@"Button_Continue",nil)
//                                              otherButtonTitles:NSLocalizedString(@"Button_ShowTutorial",nil)
//                                            ,nil];
//        [alert show];	
//        [alert release];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"encryptionTipShown"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstRunTipShown"]){
	
#ifdef ASK_FOR_TUTORIAL
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TipTitle_FirstRun", nil)
                                                        message:NSLocalizedString(@"TipMessage_FirstRun", nil)
                                                       delegate:self 
                                                        cancelButtonTitle:NSLocalizedString(@"Button_Continue", nil) otherButtonTitles:NSLocalizedString(@"Button_ShowTutorial", nil), nil];
        [alert show];	
        [alert release];
#else
        // show always on first run
        [self alertView:nil clickedButtonAtIndex:1];
#endif
	
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"firstRunTipShown"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"encryptionTipShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"firstRunTipShown"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"encryptionTipShown"];
//    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView != nil && [[alertView title] isEqualToString:NSLocalizedString(@"PromoTitle_HoccerTalk", nil)]) {
        if (buttonIndex == 1) {
            // clicked on promotion/goto appstore
            NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/hoccer/id626263090"];
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        // Tutorial Handling
        if (buttonIndex == 1) {
            HelpScrollView *helpView = [[HelpScrollView alloc] initWithNibName:@"HelpScrollView" bundle:nil];
            helpView.navigationItem.title = NSLocalizedString(@"Title_Tutorial", nil);
            CGRect screenRect;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                screenRect = [[UIScreen mainScreen] bounds];
                screenRect.size.height = screenRect.size.height - (20+44+48);
            }
            else {
                screenRect = CGRectMake(0, 0, 320, 367);
            }
            helpView.view.frame = screenRect;
            [controller pushViewController:helpView animated:YES];
            [helpView release];
        }
    }
}

- (void) dealloc {
	[controller release];
	[super dealloc];
}




@end
