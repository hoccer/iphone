
//
//  HelpController.m
//  Hoccer
//
//  Created by Robert Palmer on 04.02.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "HelpController.h"
#import "HelpScrollView.h"
#import "KSCustomPopoverBackgroundView.h"


@implementation HelpController


- (void)showTips {
    
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
    
//    // TODO temp only, remove this
//    [self alertView:nil clickedButtonAtIndex:1];    
    
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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView != nil && [[alertView title] isEqualToString:NSLocalizedString(@"PromoTitle_HoccerTalk", nil)]) {
        if (buttonIndex == 1) {
            // clicked on promotion/goto appstore
            NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/hoccer/id626263090"];
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        // Tutorial Handling
        if (buttonIndex == 1) {
            [self showTutorial];
        }
    }
}

- (void)showTutorial {    
    [self.delegate helpControllerRequestsTutorial];
}




@end
