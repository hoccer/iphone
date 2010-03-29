//
//  HoccerContentFactoryiPhone.m
//  Hoccer
//
//  Created by Robert Palmer on 25.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HoccerContentFactoryiPhone.h"
#import "HoccerVcard.h"
#import "HoccerImage.h"
#import "HoccerUrl.h"
#import "HoccerText.h"
#import "HoccerData.h"

@implementation HoccerContentFactoryIPhone

- (id <HoccerContent>)createContentFromResponse: (NSHTTPURLResponse *)response withData:(NSData *)data {
	id <HoccerContent> hoccerContent = nil;
	
	NSString *mimeType = [response MIMEType];
	
	if ([mimeType isEqual: @"text/x-vcard"]) {
		hoccerContent = [[HoccerVcard alloc] initWithData: data];
	} else if ([mimeType rangeOfString:@"image/"].location == 0) {
		hoccerContent = [[HoccerImage alloc] initWithData: data];
	} else if ([mimeType isEqual: @"text/plain"]) {
		if ([HoccerUrl isDataAUrl: data]) {
			hoccerContent = [[HoccerUrl alloc] initWithData: data];
		} else {
			hoccerContent = [[HoccerText alloc] initWithData: data];
		}
	} else {
		hoccerContent = [[HoccerData alloc] initWithData:data filename: [response suggestedFilename]];
	}
	
	
	return [hoccerContent autorelease];
}

- (BOOL) isSupportedType: (NSString *)mimeType
{
	return ([mimeType isEqual: @"text/x-vcard"] || [mimeType isEqual: @"text/plain"] 
			|| [mimeType rangeOfString:@"image/"].location == 0);
}

@end