
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
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstRunTipShown"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"encryptionTipShown"]){
		return;
	}
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"encryptionTipShown"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"firstRunTipShown"] ){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TipTitle_EncryptionAdded", nil)
                                                        message:NSLocalizedString(@"TipMessage_EncryptionAdded", nil)
                                                       delegate:self 
                                              cancelButtonTitle:@"Button_Continue" otherButtonTitles:@"Button_ShowTutorial", nil];
        [alert show];	
        [alert release];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"encryptionTipShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstRunTipShown"]){
	
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TipTitle_FirstRun", nil)
                                                        message:NSLocalizedString(@"TipMessage_FirstRun", nil)
                                                       delegate:self 
                                                        cancelButtonTitle:NSLocalizedString(@"Button_Continue", nil) otherButtonTitles:NSLocalizedString(@"Button_ShowTutorial", nil), nil];
        [alert show];	
        [alert release];
	
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"firstRunTipShown"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"encryptionTipShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }


}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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

- (void) dealloc {
	[controller release];
	[super dealloc];
}




@end
