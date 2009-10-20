//
//  ABPersonVCardCreator.m
//  Hoccer
//
//  Created by Robert Palmer on 06.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ABPersonVCardCreator.h"
#import <AddressBook/AddressBook.h>

@interface ABPersonVCardCreator (Private) 
- (void)generateVcard; 

- (NSString *)nameString;
// - (void)writePhone;
- (void)createMultiValueWithID: (ABPropertyID)propertyID toVcardProperty: (NSString *)name;
- (void)createAddress;
- (NSString *)createAddressLineFromDictonary: (CFDictionaryRef) address;
- (NSArray *)propertiesFromLabel: (CFStringRef)label;

@end



@implementation ABPersonVCardCreator

+ (NSData* )vcardWithABPerson: (ABRecordRef)record
{
	ABPersonVCardCreator *creator = [[[ABPersonVCardCreator alloc] 
									 initWithPerson:record] autorelease];
	
	return [creator vcard];
}

- (id)initWithPerson: (ABRecordRef)record
{
	self = [super init];
	if (self != nil) {
		writer = [[VcardWriter alloc] init];
		
		person = record;
		CFRetain(person);
		
		[self generateVcard];
	}
	return self;
}


- (NSData *)vcard
{
	return [[writer vcardRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
}

- (void) dealloc
{
	[writer release];
	CFRelease(person);
	
	[super dealloc];
}


- (void)generateVcard 
{
	[writer writeHeader];
	[writer writeFormattedName: [self nameString]];
	
	[self createMultiValueWithID: kABPersonPhoneProperty toVcardProperty: @"TEL"];
	[self createMultiValueWithID: kABPersonEmailProperty toVcardProperty: @"EMAIL"];
	[self createAddress];

	
	[writer writeFooter];
}

- (NSString *)nameString
{
	CFStringRef firstName = (CFStringRef) ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = (CFStringRef) ABRecordCopyValue(person, kABPersonLastNameProperty);
	
	NSString *combinedName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
	
	CFRelease(firstName);
	CFRelease(lastName);
	
	return combinedName;
}


- (void)createMultiValueWithID: (ABPropertyID)propertyID toVcardProperty: (NSString *)name
{
	ABMultiValueRef multi = ABRecordCopyValue(person, propertyID); 
	
	if (multi == NULL) {
		NSLog(@"multivalue is null"); 
		return;
	}
	
	CFStringRef phoneNumber, phoneNumberLabel;
	for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
		phoneNumber		 = ABMultiValueCopyValueAtIndex(multi, i);
		phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
		
		[writer writeProperty:name value:(NSString *)phoneNumber paramater:
					[self propertiesFromLabel:phoneNumberLabel]];		
		
		CFRelease(phoneNumber);
		CFRelease(phoneNumberLabel);
	}
	
	CFRelease(multi);
}


- (void)createAddress
{
	ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonAddressProperty);
	if (multi == NULL) return;

	CFStringRef label;
	CFDictionaryRef address;
	for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
		address = ABMultiValueCopyValueAtIndex(multi, i);
		label = ABMultiValueCopyLabelAtIndex(multi, i);
		
		[self createAddressLineFromDictonary: address];
		[writer writeProperty: @"ADR" value: [self createAddressLineFromDictonary: address]
					paramater:[[self propertiesFromLabel: label] arrayByAddingObject: @"postal"]];
		
		CFRelease(label);
		CFRelease(address);
	}
		
    CFRelease(multi);
}


- (NSString *)createAddressLineFromDictonary: (CFDictionaryRef) address
{
	int size = CFDictionaryGetCount(address);
	
	CFStringRef values[size];
	CFDictionaryGetKeysAndValues(address, NULL, (void *)&values);
	
	NSMutableString *addressLine = [NSMutableString stringWithString: (NSString *)values[0]];
	for (int i = 1; i < size; i++) {
		[addressLine appendFormat: @";%@", (NSString *)values[i]];
	}
		
	return addressLine;
}


- (NSArray *)propertiesFromLabel: (CFStringRef)label
{
	if (CFStringCompare(label, kABWorkLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo)
		return [NSArray arrayWithObjects:@"work", nil];
	
	if (CFStringCompare(label, kABHomeLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo)
		return [NSArray arrayWithObjects:@"home", nil];

	if (CFStringCompare(label, kABOtherLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo)
		return [NSArray arrayWithObjects:@"other", nil];
	
	if (CFStringCompare(label, kABPersonPhoneMainLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo)
			return [NSArray arrayWithObjects:@"home", nil];
	
	if (CFStringCompare(label, kABPersonPhoneMobileLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo) 
		return [NSArray arrayWithObjects:@"mobile", nil];
	
	if (CFStringCompare(label, kABPersonPhoneIPhoneLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo) 
		return [NSArray arrayWithObjects:@"mobile", nil];
	
	if (CFStringCompare(label, kABPersonPhoneHomeFAXLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo) 
		return [NSArray arrayWithObjects:@"home", @"fax", nil];
	
	if (CFStringCompare(label, kABPersonPhoneWorkFAXLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo) 
		return [NSArray arrayWithObjects:@"work", @"fax", nil];
	
	if (CFStringCompare(label, kABPersonPhonePagerLabel, kCFCompareCaseInsensitive) ==  kCFCompareEqualTo) 
		return [NSArray arrayWithObjects:@"pager", nil];
	
	return  [NSArray arrayWithObjects:[NSString stringWithFormat:@"x-%@", label], nil];
}

@end
