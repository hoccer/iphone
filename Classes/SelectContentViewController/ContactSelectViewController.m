//
//  ContactSelectViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 14.06.11.
//  Copyright 2011 Hoccer GmbH. All rights reserved.
//

#import "ContactSelectViewController.h"
#import "ACAddressBookPerson.h"
#import "HoccerVcard.h"

@implementation ContactSelectViewController 
@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (UIViewController *)viewController {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	return [picker autorelease];
}

#pragma mark -
#pragma mark ABPeoplePickerNavigationController delegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	ACAddressBookPerson *addressBookPerson = [[ACAddressBookPerson alloc] initWithId: (ABRecordID) ABRecordGetRecordID(person)];
	[addressBookPerson release];
	
	ABRecordID contactId = ABRecordGetRecordID(person);
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef fullPersonInfo = ABAddressBookGetPersonWithRecordID(addressBook, contactId);
	
	HoccerContent* content = [[[HoccerVcard alloc] initWitPerson:fullPersonInfo] autorelease];
	
    if ([self.delegate respondsToSelector:@selector(contentSelectController:didSelectContent:)]) {
        [self.delegate contentSelectController:self didSelectContent:content];
    }

	CFRelease(addressBook);
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    if ([self.delegate respondsToSelector:@selector(contentSelectControllerDidCancel:)]) {
        [self.delegate contentSelectControllerDidCancel:self];
    }
}




@end