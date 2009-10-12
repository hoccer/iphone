//
//  ABPersonCreatorTest.m
//  Hoccer
//
//  Created by Robert Palmer on 12.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ABPersonCreatorTest.h"
#import "ABPersonCreator.h"

@implementation ABPersonCreatorTest

- (void)testInitilaisation
{
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: @""];
	
	STAssertNotNil(creator, @"creator should not be nil");
	STAssertNotNil((void *)creator.person, @"person should not be nil"); 
	
}

- (void)testVCardParsingWithName
{
	NSString *vcardString = @"VCARD:BEGIN\r\nVERSION:3.0\r\nFN:Robert Palmer\r\nVCARD:END";
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
	
	STAssertNotNil(creator, @"creator should not be nil");
	
	ABRecordRef person = creator.person;
	
	CFStringRef firstName = (CFStringRef) ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = (CFStringRef) ABRecordCopyValue(person, kABPersonLastNameProperty);
	
	STAssertEqualObjects((NSString *)firstName, @"Robert", @"");
	STAssertEqualObjects((NSString *)lastName, @"Palmer", @"");
}

- (void)testVCardParsingWithPhone
{
	NSString *vcardString = @"VCARD:BEGIN\r\nVERSION:3.0\r\nTEL;TYPE=home:12345\r\nTEL;TYPE=work,fax:55555\r\nVCARD:END";
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
	
	STAssertNotNil(creator, @"creator should not be nil");
	
	ABRecordRef person = creator.person;
	
	ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty); 
	STAssertNotNil((void *)multi, @"");
	
	STAssertEquals((CFIndex)2, ABMultiValueGetCount(multi), @"should have two values");
	
	CFStringRef phoneNumber		 = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, 0);
	CFStringRef phoneNumberLabel = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, 0);
	STAssertEqualObjects((NSString *) phoneNumber, @"12345", @"");
	STAssertEqualObjects((NSString *) phoneNumberLabel, (NSString *) kABHomeLabel, @"");
	
	CFStringRef phoneNumber2		 = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, 1);
	CFStringRef phoneNumberLabel2 = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, 1);
	STAssertEqualObjects((NSString *) phoneNumber2, @"55555", @"");
	STAssertEqualObjects((NSString *) phoneNumberLabel2, (NSString *) kABPersonPhoneWorkFAXLabel, @"");
}

- (void)testVCardParsingWithEmail
{
	NSString *vcardString = @"VCARD:BEGIN\r\nVERSION:3.0\r\nEMAIL;TYPE=home:foo@artcom.de\r\nEMAIL;TYPE=work:foo.bar@artcom.de\r\nVCARD:END";
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
	
	STAssertNotNil(creator, @"creator should not be nil");
	
	ABRecordRef person = creator.person;
	
	ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty); 
	STAssertNotNil((void *)multi, @"");
	
	STAssertEquals((CFIndex)2, ABMultiValueGetCount(multi), @"should have two values");
	
	CFStringRef email		 = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, 0);
	CFStringRef emailLabel   = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, 0);
	STAssertEqualObjects((NSString *) email, @"foo@artcom.de", @"");
	STAssertEqualObjects((NSString *) emailLabel, (NSString *) kABHomeLabel, @"");
	
	CFStringRef email2		 = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, 1);
	CFStringRef emailLabel2  = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, 1);
	STAssertEqualObjects((NSString *) email2, @"foo.bar@artcom.de", @"");
	STAssertEqualObjects((NSString *) emailLabel2, (NSString *) kABWorkLabel, @"");
}


@end
