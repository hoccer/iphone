//
//  KnownKeysViewController.h
//  Hoccer
//
//  Created by Philip Brechler on 03.08.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicKeyManager.h"

@interface KnownKeysViewController : UITableViewController {
    PublicKeyManager *keyManager;
}

@end
