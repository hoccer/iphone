//
//  VcardWriterTests.h
//  Hoccer
//
//  Created by Robert Palmer on 06.10.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.


#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

//#import "application_headers" as required
#import "VcardWriter.h";

@interface VcardWriterTests : SenTestCase {
	VcardWriter *writer;
}

- (void)testVcardWritingProperty;
- (void)testVcardWritingPropertyWithParamaeter;

@end
