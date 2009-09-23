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



@end
