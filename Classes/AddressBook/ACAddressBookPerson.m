//
//  ACPerson.m
//  Hoccer
//
//  Created by Robert Palmer on 22.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "ACAddressBookPerson.h"

@interface ACAddressBookPerson ()

- (NSString *)stringPropertyWithId: (ABPropertyID) propertyId;
- (void)createMultiValueWithID: (ABPropertyID)propertyID toVcardProperty: (NSString *)name;
@end



@implementation ACAddressBookPerson

- (id)initWithId: (ABRecordID)recordId {
	self = [super init];
	if (self != nil) {
		personId = recordId;
		
		ABAddressBookRef addressBook = ABAddressBookCreate();
		personRecordRef = ABAddressBookGetPersonWithRecordID(addressBook, personId);
		CFRetain(personRecordRef);
		
        CFRelease(addressBook);
		[self createMultiValueWithID: kABPersonPhoneProperty toVcardProperty: @"TEL"];
	}
	
	return self;
}

- (void) dealloc
{
	CFRelease(personRecordRef);
	[super dealloc];
}


- (NSString *)name
{
	NSString *firstName = [(NSString *) ABRecordCopyValue(personRecordRef, kABPersonFirstNameProperty) autorelease];
	NSString *lastName = [(NSString *) ABRecordCopyValue(personRecordRef, kABPersonLastNameProperty) autorelease];
	
	if (lastName == NULL && firstName == NULL) {
		return nil;
	}
	
	if (lastName != NULL && firstName == NULL) {
		return lastName;
	}
	
	if (lastName == NULL && firstName != NULL) {
		return firstName;
	}
	
	return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

- (NSString *)firstName {
	return [self stringPropertyWithId:kABPersonFirstNameProperty];
}

- (NSString *)lastName {
	return [self stringPropertyWithId:kABPersonLastNameProperty];
}

- (NSString *)stringPropertyWithId: (ABPropertyID) propertyId
{
	CFStringRef property = (CFStringRef) ABRecordCopyValue(personRecordRef, propertyId);
	if (property == NULL)
		return nil;

	return [(NSString*) property autorelease];
}


- (void)createMultiValueWithID: (ABPropertyID)propertyID toVcardProperty: (NSString *)name
{
	ABMultiValueRef multi = ABRecordCopyValue(personRecordRef, propertyID); 
	
	if (multi == NULL) {
		return;
	}
	
    CFRelease(multi);
//	NSMutableArray *values = 
//	CFStringRef value, valueLabel;
//	for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
//		value	   = ABMultiValueCopyValueAtIndex(multi, i);
//		valueLabel = ABMultiValueCopyLabelAtIndex(multi, i);
//	
//		NSLog(@"value: %@", value);
//		NSLog(@"valueLabel: %@", valueLabel);
//		
//		if (value != NULL) CFRelease(value);
//		if (valueLabel != NULL) CFRelease(valueLabel);
//	}
//	
//	CFRelease(multi);
}

@end
