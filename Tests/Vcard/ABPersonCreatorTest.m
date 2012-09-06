//
//  ABPersonCreatorTest.m
//  Hoccer
//
//  Created by Robert Palmer on 12.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "GHUnit.h"
#import "ABPersonCreator.h"

@interface ABPersonCreatorTest : GHTestCase {
	
}

@end

@implementation ABPersonCreatorTest

- (void)testInitilaisation
{
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: @""];
	
	GHAssertNotNil(creator, @"creator should not be nil");
	GHAssertNotNil((void *)creator.person, @"person should not be nil"); 
	
}

- (void)testVCardParsingWithName
{
	NSString *vcardString = @"VCARD:BEGIN\r\nVERSION:3.0\r\nFN:Robert Palmer\r\nVCARD:END";
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
	
	GHAssertNotNil(creator, @"creator should not be nil");
	
	ABRecordRef person = creator.person;
	
	CFStringRef firstName = (CFStringRef) ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = (CFStringRef) ABRecordCopyValue(person, kABPersonLastNameProperty);
	
	GHAssertEqualObjects((NSString *)firstName, @"Robert", @"");
	GHAssertEqualObjects((NSString *)lastName, @"Palmer", @"");
}

- (void)testVCardParsingWithPhone
{
	NSString *vcardString = @"VCARD:BEGIN\r\nVERSION:3.0\r\nTEL;TYPE=home:12345\r\nTEL;TYPE=work,fax:55555\r\nVCARD:END";
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
	
	GHAssertNotNil(creator, @"creator should not be nil");
	
	ABRecordRef person = creator.person;
	
	ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonPhoneProperty); 
	GHAssertNotNil((void *)multi, @"");
	
	GHAssertEquals((CFIndex)2, ABMultiValueGetCount(multi), @"should have two values");
	
	CFStringRef phoneNumber		 = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, 0);
	CFStringRef phoneNumberLabel = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, 0);
	GHAssertEqualObjects((NSString *) phoneNumber, @"12345", @"");
	GHAssertEqualObjects((NSString *) phoneNumberLabel, (NSString *) kABHomeLabel, @"");
	
	CFStringRef phoneNumber2		 = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, 1);
	CFStringRef phoneNumberLabel2 = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, 1);
	GHAssertEqualObjects((NSString *) phoneNumber2, @"55555", @"");
	GHAssertEqualObjects((NSString *) phoneNumberLabel2, (NSString *) kABPersonPhoneWorkFAXLabel, @"");
}

- (void)testVCardParsingWithEmail
{
	NSString *vcardString = @"VCARD:BEGIN\r\nVERSION:3.0\r\nEMAIL;TYPE=home:foo@artcom.de\r\nEMAIL;TYPE=work:foo.bar@artcom.de\r\nVCARD:END";
	ABPersonCreator *creator = [[ABPersonCreator alloc] initWithVcardString: vcardString];
	
	GHAssertNotNil(creator, @"creator should not be nil");
	
	ABRecordRef person = creator.person;
	ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty); 
	GHAssertNotNil((void *)multi, @"");
	
	GHAssertEquals((CFIndex)2, ABMultiValueGetCount(multi), @"should have two values");
	
	CFStringRef email		 = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, 0);
	CFStringRef emailLabel   = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, 0);
	GHAssertEqualObjects((NSString *) email, @"foo@artcom.de", @"");
	GHAssertEqualObjects((NSString *) emailLabel, (NSString *) kABHomeLabel, @"");
	
	CFStringRef email2		 = (CFStringRef) ABMultiValueCopyValueAtIndex(multi, 1);
	CFStringRef emailLabel2  = (CFStringRef) ABMultiValueCopyLabelAtIndex(multi, 1);
	GHAssertEqualObjects((NSString *) email2, @"foo.bar@artcom.de", @"");
	GHAssertEqualObjects((NSString *) emailLabel2, (NSString *) kABWorkLabel, @"");
}


@end
