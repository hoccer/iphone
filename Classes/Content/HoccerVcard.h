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
#import "ContactPreview.h"


@interface HoccerVcard : HoccerContent {
	ABRecordRef person;
	ABPersonVCardCreator *abPersonVCardCreator;
	
	ABUnknownPersonViewController *unknownPersonController;
	
	ContactPreview *view;
	NSString *vcardString;
}

@property (retain) IBOutlet ContactPreview *view;

- (id)initWitPerson: (ABRecordRef) aPerson;

@end
