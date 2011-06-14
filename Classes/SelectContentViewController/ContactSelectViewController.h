//
//  ContactSelectViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 14.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ContentSelectController.h"

@interface ContactSelectViewController : NSObject <ContentSelectController, ABPeoplePickerNavigationControllerDelegate> {
    id <ContentSelectViewControllerDelegate> delegate;
}

@property (retain) id <ContentSelectViewControllerDelegate> delegate;

@end
