//
//  ContentFactoryTests.m
//  Hoccer
//
//  Created by Robert Palmer on 15.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "ContentFactoryTests.h"
#import "HoccerContent.h"
#import "HoccerContentFactory.h"

#import "HoccerImage.h"
#import "HoccerText.h"


@implementation ContentFactoryTests

- (void)testHoccerURLCreation {
	NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://www.artcom.de"]
																					 MIMEType:@"text/plain"
																		expectedContentLength:21 
																			 textEncodingName:@"UTF-8"];
	
	NSData *data = [@"http://www.artcom.de/" dataUsingEncoding: NSUTF8StringEncoding];
		
	HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse:response withData:data];
	STAssertTrue([content isKindOfClass: [HoccerText class]], @"should be right kind");
	
	[response release];
}

- (void)testHoccerImageCreation {
	NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://www.artcom.de"]
																MIMEType:@"image/jpeg"
												   expectedContentLength:21 
														textEncodingName:@"UTF-8"];
	
	HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse:response withData:nil];
	STAssertTrue([content isKindOfClass: [HoccerImage class]], @"should be right kind");
	
	[response release];
}

- (void)testHoccerTextCreation {
	NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://www.artcom.de"]
																MIMEType:@"text/plain"
												   expectedContentLength:21 
														textEncodingName:@"UTF-8"];
	
	NSData *data = [@"bla bla bla" dataUsingEncoding: NSUTF8StringEncoding];

	
	HoccerContent *content = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse:response withData: data];
	STAssertTrue([content isMemberOfClass: [HoccerText class]], @"should be right kind");
	
	[response release];
}

- (void)testHoccerUrlDetection {
	STAssertEquals(NO, [HoccerText isDataAUrl: [@"blablabla" dataUsingEncoding: NSUTF8StringEncoding]], @"should not be deteced a url");
	STAssertTrue([HoccerText isDataAUrl: [@"http://www.artcom.de" dataUsingEncoding: NSUTF8StringEncoding]], @"should be detected as url");

}



@end
