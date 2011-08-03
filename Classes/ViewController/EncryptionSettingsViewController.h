//
//  EncryptionSettingsViewController.h
//  Hoccer
//
//  Created by Philip Brechler on 01.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EncryptionSettingsViewController : UITableViewController <UITextFieldDelegate>{
    NSMutableArray *sections;
    
    
    @private
    UIView * encryptionSettingsHeader;
	UITextField *activeField;
}

@property (retain) IBOutlet UIView *encryptionSettingsHeader;

@end
