//
//  ACPerson.m
//  Hoccer
//
//  Created by Robert Palmer on 22.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "ACPerson.h"



@implementation ACPerson

- (id)initWithPerson: (ABRecordRef)aPerson 
{
	self = [super init];
	if (self != nil) {
		person = aPerson;
		CFRetain(person);
	}
	
	return self;
}

- (void) dealloc
{
	CFRelease(person);
	[super dealloc];
}


- (NSString *)name
{
	CFStringRef firstName = (CFStringRef) ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = (CFStringRef) ABRecordCopyValue(person, kABPersonLastNameProperty);
	
	if (lastName == NULL && firstName == NULL) {
		return nil;
	}
	
	if (lastName != NULL && firstName == NULL) {
		return (NSString *)lastName;
		CFRelease(lastName);
	}
	
	if (lastName == NULL && firstName != NULL) {
		return (NSString *)firstName;
		CFRelease(firstName);
	}
	
	NSString *combinedName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
	return combinedName;
}

@end
