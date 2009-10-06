//
//  VcardWriterTests.m
//  Hoccer
//
//  Created by Robert Palmer on 06.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "VcardWriterTests.h"
#import "ABPersonVCardCreator.h"



@implementation VcardWriterTests

- (void)setUp
{
	writer  = [[VcardWriter  alloc] init]; 
}

- (void)tearDown
{
	[writer release];
}


- (void)testVcardWritingProperty
{

	NSString *result = @"FN:Robert Palmer\r\n";
	[writer writeProperty:@"FN" value:@"Robert Palmer" paramater:nil];
	
	STAssertEqualObjects([writer vcardRepresentation], result, 
						 @"should be equal");
}

- (void)testVcardWritingPropertyWithParamaeter
{
	NSString *expectedResult = @"TEL;TYPE=voice,work,pref:123456789\r\n";
	
	[writer writeProperty: @"TEL" value:@"123456789" paramater:
		[NSArray arrayWithObjects: @"voice", @"work", @"pref", nil]];
	
	NSString *calculatedString = [writer vcardRepresentation];
	
	STAssertEqualObjects(calculatedString,  expectedResult,
						 @"should equal expected result");
	
}

- (void)testWriteVcardHeader
{
	NSString *expectedResult = @"BEGIN:VCARD\r\nVERSION:3.0\r\n";
	
	[writer writeHeader];
	
	STAssertEqualObjects([writer vcardRepresentation],  expectedResult,
						 @"should equal expected result");
}

- (void)testWriteVcardFooter
{
	NSString *expectedResult = @"END:VCARD";
	[writer writeFooter];

	STAssertEqualObjects([writer vcardRepresentation],  expectedResult,
						 @"should equal expected result");
}


- (void)testABPersonCreation
{
	ABRecordRef person = ABPersonCreate();
	CFErrorRef errorRef;
	ABRecordSetValue(person, kABPersonFirstNameProperty, @"foo", &errorRef);
	
	CFStringRef name = (CFStringRef) ABRecordCopyValue(person, kABPersonFirstNameProperty);
	
	STAssertEqualObjects((NSString *)name, @"foo", @"names should match");
	
	CFRelease(name);
}

- (void)testABPersonToVCard
{
	CFErrorRef errorRef;

	ABRecordRef person = ABPersonCreate();
	ABRecordSetValue(person, kABPersonFirstNameProperty, @"Foo", &errorRef);
	ABRecordSetValue(person, kABPersonLastNameProperty, @"Bar", &errorRef);
	ABRecordSetValue(person, kABPersonOrganizationProperty, @"Art+Com Technologies", &errorRef);
	ABRecordSetValue(person, kABPersonJobTitleProperty, @"Developer", &errorRef);
	
	
	ABMutableMultiValueRef email= ABMultiValueCreateMutable(kABMultiStringPropertyType);
	//ABMultiValueAddValueAndLabel(email, @"foo.bar@artcom.de", kABWorkLabel, NULL);
	ABMultiValueAddValueAndLabel(email, @"foo@artcom.de", kABWorkLabel, NULL);
	ABRecordSetValue(person, kABPersonEmailProperty, email, &errorRef);
	CFRelease(email);
	
	ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	ABMultiValueAddValueAndLabel(multi, @"555", kABPersonPhoneMobileLabel, NULL);
	ABMultiValueAddValueAndLabel(multi, @"666", kABPersonPhoneMainLabel, NULL);
	
	ABRecordSetValue(person, kABPersonPhoneProperty, multi, &errorRef);
	CFRelease(multi);
	
	NSData *vcardData  = [ABPersonVCardCreator vcardWithABPerson: person];
	STAssertNotNil(vcardData, @"should not be nil");
	
	NSString *vcardString = [[[NSString  alloc] initWithData:vcardData encoding:NSUTF8StringEncoding]  autorelease];
	
	STAssertEqualObjects(vcardString, @"BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Foo Bar\r\nTEL;TYPE=mobile:555\r\nTEL;TYPE=home:666\r\nEMAIL;TYPE=work:foo@artcom.de\r\nEND:VCARD", 
						 @"vcards should match");
	
	CFRelease(person);	
}




@end
