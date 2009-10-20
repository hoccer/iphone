//
//  ABPersonCreator.m
//  Hoccer
//
//  Created by Robert Palmer on 12.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ABPersonCreator.h"
#import "VcardParser.h"

@interface ABPersonCreator (Private)

- (CFStringRef)labelFromAttributes: (NSArray *)attributes;
- (CFDictionaryRef)createDirectoryFromAddressString: (NSString *)address;

@end




@implementation ABPersonCreator

@synthesize person;

- (id) initWithVcardString: (NSString *)vcard
{
	self = [super init];
	if (self != nil) {
		person = ABPersonCreate();
		NSLog(@"vcard: %@", vcard);
		
		VcardParser *parser = [[VcardParser alloc] initWithString:vcard];
		parser.delegate = self;
		
		[parser parse];
		[parser release];
	}
	return self;
}

- (void) dealloc
{
	CFRelease(person);
	[super dealloc];
}


#pragma mark -
#pragma mark VcardParserDelegate Methods


- (void)parser: (VcardParser*)parser didFoundFormattedName: (NSString *)name
{
	NSArray *splittedName = [name componentsSeparatedByString:@" "];
	
	CFErrorRef error;
	if([splittedName count] < 1)
		return;
	
	ABRecordSetValue(person, kABPersonFirstNameProperty, 
					 [splittedName objectAtIndex:0], &error);
	
	if ([splittedName count] > 1) {
		ABRecordSetValue(person, kABPersonLastNameProperty, 
						 [splittedName objectAtIndex:1], &error);
	}
}


- (void)parser: (VcardParser*)parser didFoundPhoneNumber: (NSString*)number 
										  withAttributes: (NSArray *)attributes
{
	ABMultiValueRef currentPhoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
	CFErrorRef errorRef;

	ABMutableMultiValueRef numbers = NULL;
	if (currentPhoneNumbers == NULL) {
		numbers= ABMultiValueCreateMutable(kABMultiStringPropertyType);
	} else {
		numbers = ABMultiValueCreateMutableCopy(currentPhoneNumbers);
	}

	
	ABMultiValueAddValueAndLabel(numbers, number, [self labelFromAttributes: attributes], NULL);
	ABRecordSetValue(person, kABPersonPhoneProperty, numbers, &errorRef);
	
	CFRelease(numbers);
	
	if (currentPhoneNumbers != NULL)
		CFRelease(currentPhoneNumbers);
}


- (void)parser: (VcardParser*)parser didFoundEmail: (NSString*)email 
									withAttributes: (NSArray *)attributes 
{
	ABMultiValueRef currentEmaiAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
	CFErrorRef errorRef;

	ABMutableMultiValueRef emails = NULL;
	if (currentEmaiAddresses == NULL) {
		emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	} else {
		emails = ABMultiValueCreateMutableCopy(currentEmaiAddresses);
	}
	
	ABMultiValueAddValueAndLabel(emails, email, [self labelFromAttributes: attributes], NULL);
	ABRecordSetValue(person, kABPersonEmailProperty, emails, &errorRef);

	CFRelease(emails);
	
	if (currentEmaiAddresses != NULL)
		CFRelease(currentEmaiAddresses);
}


- (void)parser: (VcardParser*)parser didFoundAddress: (NSString*)address 
									  withAttributes: (NSArray *)attributes
{
	ABMultiValueRef currentMultiValue = ABRecordCopyValue(person, kABPersonAddressProperty);
	CFErrorRef errorRef;
	
	ABMutableMultiValueRef addresses = NULL;
	if (currentMultiValue == NULL) {
		addresses = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	} else {
		addresses = ABMultiValueCreateMutableCopy(currentMultiValue);
	}
	
	CFDictionaryRef addressDict = [self createDirectoryFromAddressString: address];
	ABMultiValueAddValueAndLabel(addresses, addressDict,
								 [self labelFromAttributes: attributes], NULL);
								 
	CFRelease(addressDict);
	
	ABRecordSetValue(person, kABPersonAddressProperty, addresses, &errorRef);
	
	CFRelease(addresses);
	if (currentMultiValue != NULL)
		CFRelease(currentMultiValue);
}



#pragma mark -
#pragma mark Private Methods

- (CFStringRef)labelFromAttributes: (NSArray *)attributes
{
	NSLog(@"attributes: %@", attributes);
	if([attributes isEqualToArray: [NSArray arrayWithObjects:@"work", nil]])
		return kABWorkLabel;
	
	if ([attributes isEqualToArray: [NSArray arrayWithObjects:@"home", nil]])
		 return kABHomeLabel;
	
	if  ([attributes isEqualToArray:[NSArray arrayWithObjects:@"other", nil]])
		return kABOtherLabel;
	
	if([attributes isEqualToArray: [NSArray arrayWithObjects:@"mobile", nil]])
		return kABPersonPhoneMobileLabel;

	if ([attributes isEqualToArray: [NSArray arrayWithObjects:@"home", @"fax", nil]])
		return kABPersonPhoneHomeFAXLabel;
	
	if ([attributes isEqualToArray:[NSArray arrayWithObjects:@"work", @"fax", nil]])
		return kABPersonPhoneWorkFAXLabel;
	
	if ([attributes isEqualToArray: [NSArray arrayWithObjects:@"pager", nil]])
		return kABPersonPhonePagerLabel;
	
	return kABOtherLabel;
}


- (CFDictionaryRef)createDirectoryFromAddressString: (NSString *)address
{
	NSArray *addressParts = [address componentsSeparatedByString:@";"];
	if (!addressParts)
		return nil;
	
	CFStringRef keys[5];
	CFStringRef values[5];
	keys[0]      = kABPersonAddressStreetKey;
	keys[1]      = kABPersonAddressCityKey;
	keys[2]      = kABPersonAddressStateKey;
	keys[3]      = kABPersonAddressZIPKey;
	keys[4]      = kABPersonAddressCountryKey;

	values[0]    = (CFStringRef) [addressParts objectAtIndex:0];
	
	if ([addressParts count] > 1)
		values[1]  = (CFStringRef) [addressParts objectAtIndex:1];
	if ([addressParts count] > 2)
		values[2]  = (CFStringRef) [addressParts objectAtIndex:2];
	if ([addressParts count] > 3)
		values[3]  = (CFStringRef) [addressParts objectAtIndex:3];
	if ([addressParts count] > 4)
		values[4]  = (CFStringRef) [addressParts objectAtIndex:4];
	
	CFDictionaryRef aDict = CFDictionaryCreate(NULL,
											   (void *)keys,
											   (void *)values,
											   [addressParts count],
											   &kCFCopyStringDictionaryKeyCallBacks,
											   &kCFTypeDictionaryValueCallBacks);
	return aDict;	
}


@end
