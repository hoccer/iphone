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

@end




@implementation ABPersonCreator

@synthesize person;

- (id) initWithVcardString: (NSString *)vcard
{
	self = [super init];
	if (self != nil) {
		person = ABPersonCreate();
		
		VcardParser *parser = [[VcardParser alloc] initWithString:vcard];
		parser.delegate = self;
		
		[parser parse];
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
	ABMultiValueRef currentMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
	CFErrorRef errorRef;

	ABMutableMultiValueRef numbers = NULL;
	if (currentMultiValue == NULL) {
		numbers= ABMultiValueCreateMutable(kABMultiStringPropertyType);
	} else {
		numbers = ABMultiValueCreateMutableCopy(currentMultiValue);
	}
	
	ABMultiValueAddValueAndLabel(numbers, number, [self labelFromAttributes: attributes], NULL);
	ABRecordSetValue(person, kABPersonPhoneProperty, numbers, &errorRef);
}


- (void)parser: (VcardParser*)parser didFoundEmail: (NSString*)email 
									withAttributes: (NSArray *)attributes 
{
	ABMultiValueRef currentMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
	CFErrorRef errorRef;

	ABMutableMultiValueRef emails = NULL;
	if (currentMultiValue == NULL) {
		emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	} else {
		emails = ABMultiValueCreateMutableCopy(currentMultiValue);
	}
	
	ABMultiValueAddValueAndLabel(emails, email, [self labelFromAttributes: attributes], NULL);
	ABRecordSetValue(person, kABPersonEmailProperty, emails, &errorRef);
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
		emails = ABMultiValueCreateMutableCopy(currentMultiValue);
	}
	

	
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


@end
