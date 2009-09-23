//
//  FeaturePattern.m
//  Hoccer
//
//  Created by Robert Palmer on 23.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "RegExpTests.h"
#import "NSString+Regexp.h"


@implementation RegExpTests


- (void)testTrueRegExp
{
	NSString *string = @"<up><up><down>";
	STAssertTrue([string matches: @"^<up>.*<down>$"], @"should match regexp expression");
}

- (void)testFalseRedExp
{
	NSString *string = @"<bla><bla>";
	STAssertFalse([string matches:@"<test>"], @"should not match regex expression");
}

- (void)testRegExpWithW
{
	NSString *pattern = @"<up><fastdown><fastup><up><fastdown>";

	STAssertTrue([pattern matches:@"<[a-zA-Z]*>"], @"should match");
}


- (void)testMatchingPattern
{
	NSString *pattern = @"<up><down><up><flat><up>";
	
	STAssertTrue([pattern matchesFeaturePattern:@"<up>*<up>"], @"should match");
	STAssertFalse([pattern matchesFeaturePattern:@"<up>*<down>"], @"should not match");
	STAssertFalse([pattern matchesFeaturePattern:@"<flat>*<up>"], @"should not match");

	STAssertTrue([pattern matchesFeaturePattern:@"<up><down>*<up>"], @"should match");
	STAssertTrue([pattern matchesFeaturePattern:@"<up>*<up>*<up>"], @"should match");
	STAssertTrue([pattern matchesFeaturePattern:@"*<flat>*"], @"should match");
}

- (void)testAsterixInsideOfFeatures
{
	NSString *pattern = @"<up><fastdown><fastup><up><fastdown>";

	STAssertTrue([pattern matchesFeaturePattern:@"*<*up>*"], @"should match");
	STAssertTrue([pattern matchesFeaturePattern:@"*<*up><*down>"], @"should match");
	STAssertTrue([pattern matchesFeaturePattern:@"<*up><fastdown><fastup>*"], @"should match");

	STAssertFalse([pattern matchesFeaturePattern:@"*<up><*up>*"], @"should not match");
	STAssertFalse([pattern matchesFeaturePattern:@"*<fast*><fast*><fast*>*"], @"should not match");
	STAssertTrue([pattern matchesFeaturePattern:@"*<fast*><fast*>*<fast*>"], @"should match");
}



@end
