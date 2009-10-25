//
//  HoccerVcard.h
//  Hoccer
//
//  Created by Robert Palmer on 19.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

#import "HoccerContent.h"
#import "ABPersonVCardCreator.h"

@interface HoccerVcard : NSObject <HoccerContent> {
	ABRecordRef person;
	ABPersonVCardCreator *acPerson;
	
	ABUnknownPersonViewController *unknownPersonController;
}

- (id)initWitPerson: (ABRecordRef) aPerson;

@end
