//
//  HoccerContentFacoryIPad.m
//  Hoccer
//
//  Created by Robert Palmer on 25.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerContentFactoryIPad.h"
#import "HoccerDataiPad.h"

@implementation HoccerContentFactoryIPad

- (id <HoccerContent>)createContentFromResponse: (NSHTTPURLResponse *)response withData:(NSData *)data {
//	id <HoccerContent> hoccerContent = nil;
	
//	NSString *mimeType = [response MIMEType];
//	
//	if ([mimeType isEqual: @"text/x-vcard"]) {
//		hoccerContent = [[HoccerVcard alloc] initWithData: data];
//	} else if ([mimeType rangeOfString:@"image/"].location == 0) {
//		hoccerContent = [[HoccerImage alloc] initWithData: data];
//	} else if ([mimeType isEqual: @"text/plain"]) {
//		if ([HoccerUrl isDataAUrl: data]) {
//			hoccerContent = [[HoccerUrl alloc] initWithData: data];
//		} else {
//			hoccerContent = [[HoccerText alloc] initWithData: data];
//		}
//	} else {
//		hoccerContent = [[HoccerData alloc] initWithData:data filename: [response suggestedFilename]];
//	}
	
	id <HoccerContent> hoccerContent = [[HoccerDataiPad alloc] initWithData:data filename: [response suggestedFilename]];
	return [hoccerContent autorelease];
}

- (BOOL) isSupportedType: (NSString *)mimeType
{
	return ([mimeType isEqual: @"text/x-vcard"] || [mimeType isEqual: @"text/plain"] 
			|| [mimeType rangeOfString:@"image/"].location == 0);
}

@end
