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
	NSString *firstName = [(NSString *) ABRecordCopyValue(person, kABPersonFirstNameProperty) autorelease];
	NSString *lastName = [(NSString *) ABRecordCopyValue(person, kABPersonLastNameProperty) autorelease];
	
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

@end
