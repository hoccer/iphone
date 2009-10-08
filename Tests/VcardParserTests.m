//
//  VcardParserTests.m
//  Hoccer
//
//  Created by Robert Palmer on 08.10.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "VcardParserTests.h"
#import "VcardParser.h"

#import "MockedParserDelegate.h"

@implementation VcardParserTests

- (void)testParserCreation
{
	VcardParser *parser = [[VcardParser alloc] initWithString:@""];
	STAssertNotNil(parser, @"should not be nil");
	[parser release];
}


- (void)testIsValidVcard
{
	VcardParser *parser = [[VcardParser alloc] initWithString:@"BEGIN:VCARD\r\nVERSION:3.0\r\nEND:VCARD"];
	STAssertNotNil(parser, @"should not be nil");
	STAssertTrue([parser isValidVcard], @"vcard should be valid");
	[parser release];
}

- (void)testIsInvalidVcard
{
	VcardParser *parser = [[VcardParser alloc] initWithString:@"BEGIN:BLAAA\r\nVERSION:3.0\r\nEND:VCARD"];
	STAssertFalse([parser isValidVcard], @"vcard should not be valid");	
}

- (void)testIsInvalidVcardWhenToShort
{
	VcardParser *parser = [[VcardParser alloc] initWithString:@"BEGIN:BLAAA"];
	STAssertFalse([parser isValidVcard], @"vcard should not be valid");	
}


- (void)testParserDetectsName
{
	VcardParser *parser = [[VcardParser alloc] initWithString:@"BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Robert Palmer\r\nEND:VCARD"];
	MockedParserDelegate *mockedParserDelegate = [[MockedParserDelegate alloc] init];
	parser.delegate = mockedParserDelegate;
	
	[parser parse];
	
	STAssertEqualObjects(mockedParserDelegate.foundProperty, @"FN", @"should be FN");
	
}


- (void)testParserDetectsTel
{
	VcardParser *parser = [[VcardParser alloc] initWithString:@"BEGIN:VCARD\r\nVERSION:3.0\r\nTEL;TYPE=home:123456\r\nEND:VCARD"];
	MockedParserDelegate *mockedParserDelegate = [[MockedParserDelegate alloc] init];
	parser.delegate = mockedParserDelegate;
	
	[parser parse];
	
	STAssertEqualObjects(mockedParserDelegate.foundProperty, @"TEL", @"should be TEL");
}



@end
